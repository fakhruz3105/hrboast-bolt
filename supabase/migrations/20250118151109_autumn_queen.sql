-- Drop existing function
DROP FUNCTION IF EXISTS get_staff_memo_list;

-- Create improved function with unambiguous column references
CREATE OR REPLACE FUNCTION get_staff_memo_list(p_staff_id uuid)
RETURNS TABLE (
  id uuid,
  title text,
  type memo_type,
  content text,
  department_id uuid,
  staff_id uuid,
  created_at timestamptz,
  updated_at timestamptz,
  department_name text,
  staff_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    m.title,
    m.type,
    m.content,
    m.department_id,
    m.staff_id,
    m.created_at,
    m.updated_at,
    d.name as department_name,
    s2.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s2 ON m.staff_id = s2.id
  JOIN staff s ON s.id = p_staff_id
  WHERE 
    -- All staff memos for this company
    (m.department_id IS NULL AND m.staff_id IS NULL AND m.company_id = s.company_id) OR
    -- Department memos for staff's departments
    m.department_id IN (
      SELECT sd.department_id 
      FROM staff_departments sd
      WHERE sd.staff_id = p_staff_id
    ) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;