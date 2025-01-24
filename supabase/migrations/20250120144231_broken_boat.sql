-- Drop existing function
DROP FUNCTION IF EXISTS get_company_warning_letters;

-- Create improved function with better company isolation and debugging
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
  -- Return warning letters with proper company isolation
  RETURN QUERY
  WITH staff_members AS (
    -- First get all staff for the company
    SELECT s.id, s.name, s.company_id
    FROM staff s
    WHERE s.company_id = p_company_id
  ),
  staff_departments AS (
    -- Get primary departments for staff
    SELECT 
      sd.staff_id,
      d.name as department_name
    FROM staff_departments sd
    JOIN departments d ON sd.department_id = d.id
    WHERE sd.is_primary = true
    AND sd.staff_id IN (SELECT id FROM staff_members)
  )
  SELECT DISTINCT ON (wl.id)
    wl.id,
    wl.staff_id,
    upper(wl.warning_level::text),
    wl.incident_date,
    wl.description,
    wl.improvement_plan,
    wl.consequences,
    wl.issued_date,
    wl.show_cause_response,
    wl.response_submitted_at,
    sm.name as staff_name,
    sd.department_name
  FROM warning_letters wl
  JOIN staff_members sm ON wl.staff_id = sm.id
  LEFT JOIN staff_departments sd ON wl.staff_id = sd.staff_id
  WHERE sm.company_id = p_company_id
  ORDER BY wl.id, wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to debug warning letters
CREATE OR REPLACE FUNCTION debug_warning_letters(p_company_id uuid)
RETURNS TABLE (
  warning_letter_id uuid,
  staff_id uuid,
  staff_name text,
  staff_company_id uuid,
  warning_level text,
  issued_date date
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    wl.id as warning_letter_id,
    wl.staff_id,
    s.name as staff_name,
    s.company_id as staff_company_id,
    wl.warning_level::text,
    wl.issued_date
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  WHERE s.company_id = p_company_id
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Ensure warning letters have correct company_id
UPDATE warning_letters wl
SET company_id = s.company_id
FROM staff s
WHERE wl.staff_id = s.id
AND (wl.company_id IS NULL OR wl.company_id != s.company_id);

-- Create index for better performance if not exists
CREATE INDEX IF NOT EXISTS idx_warning_letters_company_staff 
ON warning_letters(company_id, staff_id);

-- Update RLS policies
DROP POLICY IF EXISTS "warning_letters_select" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_insert" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_update" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_delete" ON warning_letters;

CREATE POLICY "warning_letters_select"
  ON warning_letters FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = warning_letters.staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "warning_letters_insert"
  ON warning_letters FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "warning_letters_update"
  ON warning_letters FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = warning_letters.staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "warning_letters_delete"
  ON warning_letters FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = warning_letters.staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );