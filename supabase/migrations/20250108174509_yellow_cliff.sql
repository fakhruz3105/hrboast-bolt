-- Drop existing policies
DROP POLICY IF EXISTS "memos_select" ON memos;
DROP POLICY IF EXISTS "memos_insert" ON memos;
DROP POLICY IF EXISTS "memos_delete" ON memos;

-- Create better RLS policies
CREATE POLICY "memos_select_policy"
  ON memos FOR SELECT
  USING (
    -- Staff can see:
    -- 1. All staff memos (no department or staff specified)
    -- 2. Their department memos
    -- 3. Personal memos addressed to them
    department_id IS NULL OR 
    department_id IN (
      SELECT department_id FROM staff WHERE id = auth.uid()
    ) OR 
    staff_id = auth.uid()
  );

CREATE POLICY "memos_insert_policy"
  ON memos FOR INSERT
  WITH CHECK (
    -- Only admins and HR can create memos
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "memos_delete_policy"
  ON memos FOR DELETE
  USING (
    -- Only admins and HR can delete memos
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

-- Add function to get memos for a staff member
CREATE OR REPLACE FUNCTION get_staff_memos(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  title text,
  type text,
  content text,
  department_name text,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    m.id,
    m.title,
    m.type::text,
    m.content,
    d.name as department_name,
    m.created_at
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  WHERE 
    m.department_id IS NULL OR -- All staff memos
    m.department_id = (SELECT department_id FROM staff WHERE id = staff_uid) OR -- Department memos
    m.staff_id = staff_uid -- Personal memos
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;