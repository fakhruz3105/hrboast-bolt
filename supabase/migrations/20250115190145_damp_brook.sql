-- Drop existing function
DROP FUNCTION IF EXISTS get_staff_eligible_benefits;

-- Create improved function with simplified benefit structure
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
BEGIN
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
    EXISTS (
      SELECT 1 
      FROM benefit_eligibility be
      JOIN staff_levels_junction slj ON be.level_id = slj.level_id
      WHERE be.benefit_id = b.id 
      AND slj.staff_id = staff_uid
      AND slj.is_primary = true
    ) as is_eligible
  FROM benefits b
  WHERE b.status = true
  AND b.company_id = (
    SELECT company_id 
    FROM staff 
    WHERE id = staff_uid
  )
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;