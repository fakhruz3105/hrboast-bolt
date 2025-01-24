-- Drop existing function
DROP FUNCTION IF EXISTS get_staff_memos;

-- Create improved function with explicit column references
CREATE OR REPLACE FUNCTION get_staff_memos(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  title text,
  type memo_type,
  content text,
  department_id uuid,
  staff_id uuid,
  created_at timestamptz,
  updated_at timestamptz,
  department_name text
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
    d.name as department_name
  FROM memos m
  LEFT JOIN departments d ON m.department_id = d.id
  WHERE 
    m.department_id IS NULL OR -- All staff memos
    m.department_id = (
      SELECT s.department_id 
      FROM staff s 
      WHERE s.id = staff_uid
    ) OR -- Department memos
    m.staff_id = staff_uid -- Personal memos
  ORDER BY m.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Drop existing policies
DROP POLICY IF EXISTS "memos_select_policy" ON memos;
DROP POLICY IF EXISTS "memos_insert_policy" ON memos;
DROP POLICY IF EXISTS "memos_delete_policy" ON memos;

-- Create simplified RLS policies
CREATE POLICY "memos_select"
  ON memos FOR SELECT
  USING (true);

CREATE POLICY "memos_insert"
  ON memos FOR INSERT
  WITH CHECK (true);

CREATE POLICY "memos_delete"
  ON memos FOR DELETE
  USING (true);

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_memos_all_fields ON memos(department_id, staff_id, created_at);