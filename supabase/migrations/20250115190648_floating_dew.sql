-- Drop existing function if it exists
DROP FUNCTION IF EXISTS get_staff_eligible_benefits;

-- Create improved function to get staff eligible benefits
CREATE OR REPLACE FUNCTION get_staff_eligible_benefits(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  created_at timestamptz,
  updated_at timestamptz,
  is_eligible boolean
) AS $$
DECLARE
  v_company_id uuid;
BEGIN
  -- Get staff's company_id
  SELECT company_id INTO v_company_id
  FROM staff
  WHERE id = staff_uid;

  -- Initialize benefits if none exist for this company
  IF NOT EXISTS (
    SELECT 1 FROM benefits WHERE company_id = v_company_id
  ) THEN
    PERFORM initialize_company_benefits(v_company_id);
  END IF;

  -- Return benefits with eligibility
  RETURN QUERY
  SELECT DISTINCT ON (b.id)
    b.id,
    b.name,
    b.description,
    b.amount,
    b.status,
    b.frequency,
    b.created_at,
    b.updated_at,
    EXISTS (
      SELECT 1 
      FROM benefit_eligibility be
      JOIN staff_levels_junction slj ON be.level_id = slj.level_id
      WHERE be.benefit_id = b.id 
      AND slj.staff_id = staff_uid
      AND slj.is_primary = true
    ) as is_eligible
  FROM benefits b
  WHERE b.company_id = v_company_id
  AND b.status = true
  ORDER BY b.id, b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Initialize benefits for all existing companies
DO $$
DECLARE
  v_company RECORD;
BEGIN
  FOR v_company IN SELECT id FROM companies LOOP
    IF NOT EXISTS (
      SELECT 1 FROM benefits WHERE company_id = v_company.id
    ) THEN
      PERFORM initialize_company_benefits(v_company.id);
    END IF;
  END LOOP;
END $$;