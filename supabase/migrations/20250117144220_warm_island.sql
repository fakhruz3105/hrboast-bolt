-- Create or replace function to get staff eligible benefits with company isolation
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
  v_staff_status staff_status;
BEGIN
  -- Get staff's company_id and status
  SELECT s.company_id, s.status INTO v_company_id, v_staff_status
  FROM staff s
  WHERE s.id = staff_uid;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  RETURN QUERY
  SELECT 
    b.id,
    b.name,
    b.description,
    b.amount,
    b.status,
    b.frequency,
    b.created_at,
    b.updated_at,
    CASE 
      WHEN v_staff_status = 'probation' THEN false  -- Probation staff are not eligible
      ELSE EXISTS (
        SELECT 1 
        FROM benefit_eligibility be
        JOIN staff_levels_junction slj ON be.level_id = slj.level_id
        WHERE be.benefit_id = b.id 
        AND slj.staff_id = staff_uid
        AND slj.is_primary = true
      )
    END as is_eligible
  FROM benefits b
  WHERE b.company_id = v_company_id
  AND b.status = true
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;