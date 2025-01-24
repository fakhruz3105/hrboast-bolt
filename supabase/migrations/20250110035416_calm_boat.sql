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
  SELECT DISTINCT
    m.id,
    m.title,
    m.type,
    m.content,
    m.department_id,
    m.staff_id,
    m.created_at,
    m.updated_at,
    d.name as department_name,
    s.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s ON m.staff_id = s.id
  LEFT JOIN staff_departments sd ON 
    CASE 
      WHEN m.department_id IS NOT NULL THEN sd.department_id = m.department_id AND sd.staff_id = p_staff_id
      ELSE true
    END
  WHERE 
    -- All staff memos (no department or staff specified)
    (m.department_id IS NULL AND m.staff_id IS NULL) OR
    -- Department memos for staff's departments
    (m.department_id IS NOT NULL AND sd.staff_id = p_staff_id) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;