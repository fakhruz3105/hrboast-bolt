-- Drop existing policies if they exist
DROP POLICY IF EXISTS "warning_letters_select" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_insert" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_update" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_delete" ON warning_letters;

-- Create simplified RLS policies
CREATE POLICY "warning_letters_select"
  ON warning_letters FOR SELECT
  USING (true);  -- Allow all authenticated users to read warning letters

CREATE POLICY "warning_letters_insert"
  ON warning_letters FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create warning letters

CREATE POLICY "warning_letters_update"
  ON warning_letters FOR UPDATE
  USING (true);  -- Allow all authenticated users to update warning letters

CREATE POLICY "warning_letters_delete"
  ON warning_letters FOR DELETE
  USING (true);  -- Allow all authenticated users to delete warning letters

-- Create function to get warning letters for a company
CREATE OR REPLACE FUNCTION get_company_warning_letters(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  warning_level text,
  incident_date date,
  description text,
  improvement_plan text,
  consequences text,
  issued_date date,
  show_cause_response text,
  response_submitted_at timestamptz,
  staff_name text,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (wl.id)  -- Use DISTINCT ON to avoid duplicates
    wl.id,
    wl.staff_id,
    upper(wl.warning_level::text),  -- Convert to uppercase
    wl.incident_date,
    wl.description,
    wl.improvement_plan,
    wl.consequences,
    wl.issued_date,
    wl.show_cause_response,
    wl.response_submitted_at,
    s.name as staff_name,
    d.name as department_name
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE s.company_id = p_company_id
  ORDER BY wl.id, wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Ensure all warning letters have company_id set
UPDATE warning_letters wl
SET company_id = s.company_id
FROM staff s
WHERE wl.staff_id = s.id
AND wl.company_id IS NULL;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_warning_letters_company 
ON warning_letters(company_id);

CREATE INDEX IF NOT EXISTS idx_warning_letters_staff 
ON warning_letters(staff_id);

CREATE INDEX IF NOT EXISTS idx_warning_letters_issued_date 
ON warning_letters(issued_date);