-- Drop and recreate the function with unambiguous column references
CREATE OR REPLACE FUNCTION get_staff_eligible_benefits(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  frequency_period integer,
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
    b.frequency::text,
    b.frequency_period,
    b.created_at,
    b.updated_at,
    EXISTS (
      SELECT 1 
      FROM benefit_eligibility be
      JOIN staff s ON s.level_id = be.level_id
      WHERE be.benefit_id = b.id 
      AND s.id = staff_uid
    ) as is_eligible
  FROM benefits b
  WHERE b.status = true
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;