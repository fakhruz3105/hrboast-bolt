-- Drop existing policies
DROP POLICY IF EXISTS "memos_select" ON memos;
DROP POLICY IF EXISTS "memos_insert" ON memos;
DROP POLICY IF EXISTS "memos_delete" ON memos;

-- Create improved RLS policies
CREATE POLICY "memos_select"
  ON memos FOR SELECT
  USING (true);  -- Allow all authenticated users to read memos

CREATE POLICY "memos_insert"
  ON memos FOR INSERT
  WITH CHECK (
    -- Only admins and HR can create memos
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "memos_delete"
  ON memos FOR DELETE
  USING (
    -- Only admins and HR can delete memos
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

-- Create function to get memos for a staff member
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
    s.name as staff_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  LEFT JOIN staff s ON m.staff_id = s.id
  WHERE 
    -- All staff memos
    (m.department_id IS NULL AND m.staff_id IS NULL) OR
    -- Department memos for staff's department
    m.department_id = (
      SELECT department_id 
      FROM staff 
      WHERE id = p_staff_id
    ) OR
    -- Personal memos
    m.staff_id = p_staff_id
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;