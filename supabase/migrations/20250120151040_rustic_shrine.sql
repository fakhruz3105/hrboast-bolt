-- Drop existing function
DROP FUNCTION IF EXISTS get_company_exit_interviews;

-- Create improved function that includes show cause response
CREATE OR REPLACE FUNCTION get_company_exit_interviews(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  title text,
  content jsonb,
  status text,
  issued_date timestamptz,
  staff_name text,
  department_name text,
  response text,
  response_date timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.staff_id,
    l.title,
    l.content,
    l.status::text,
    l.issued_date,
    s.name as staff_name,
    d.name as department_name,
    l.content->>'response' as response,
    (l.content->>'response_date')::timestamptz as response_date
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'show_cause'
  AND s.company_id = p_company_id
  ORDER BY l.created_at DESC;
END;
$$ LANGUAGE plpgsql;