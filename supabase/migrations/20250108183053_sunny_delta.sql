-- Drop existing function if it exists
DROP FUNCTION IF EXISTS get_staff_memos;

-- Drop existing policies
DROP POLICY IF EXISTS "memos_select" ON memos;
DROP POLICY IF EXISTS "memos_insert" ON memos;
DROP POLICY IF EXISTS "memos_delete" ON memos;

-- Create improved RLS policies
CREATE POLICY "memos_select"
  ON memos FOR SELECT
  USING (
    -- Staff can see:
    -- 1. All staff memos (no department or staff specified)
    -- 2. Their department memos
    -- 3. Personal memos addressed to them
    (department_id IS NULL AND staff_id IS NULL) OR -- All staff memos
    department_id = (
      SELECT department_id 
      FROM staff 
      WHERE id = auth.uid()
    ) OR -- Department memos
    staff_id = auth.uid() -- Personal memos
  );

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

-- Create new function with a different name to avoid conflicts
CREATE OR REPLACE FUNCTION get_staff_memo_details(p_staff_id uuid)
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