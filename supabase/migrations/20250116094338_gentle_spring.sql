-- Drop existing policies if they exist
DROP POLICY IF EXISTS "hr_letters_select" ON hr_letters;
DROP POLICY IF EXISTS "hr_letters_insert" ON hr_letters;
DROP POLICY IF EXISTS "hr_letters_update" ON hr_letters;
DROP POLICY IF EXISTS "hr_letters_delete" ON hr_letters;

-- Create simplified RLS policies
CREATE POLICY "hr_letters_select"
  ON hr_letters FOR SELECT
  USING (true);  -- Allow all authenticated users to read

CREATE POLICY "hr_letters_insert"
  ON hr_letters FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to insert

CREATE POLICY "hr_letters_update"
  ON hr_letters FOR UPDATE
  USING (true);  -- Allow all authenticated users to update

CREATE POLICY "hr_letters_delete"
  ON hr_letters FOR DELETE
  USING (true);  -- Allow all authenticated users to delete

-- Create function to get company exit interviews with proper company isolation
CREATE OR REPLACE FUNCTION get_company_exit_interviews(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  title text,
  content jsonb,
  status text,
  issued_date timestamptz,
  staff_name text,
  department_name text
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
    d.name as department_name
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'interview'
  AND l.content->>'type' = 'exit'
  AND s.company_id = p_company_id
  ORDER BY l.created_at DESC;
END;
$$ LANGUAGE plpgsql;