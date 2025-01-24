-- Drop existing function
DROP FUNCTION IF EXISTS get_company_warning_letters;

-- Create improved function with fully qualified column references
CREATE OR REPLACE FUNCTION get_company_warning_letters(p_company_id uuid)
RETURNS TABLE (
  warning_letter_id uuid,
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
  WITH staff_members AS (
    -- First get all staff for the company with explicit column aliases
    SELECT 
      staff.id AS staff_member_id,
      staff.name AS staff_member_name,
      staff.company_id AS staff_company_id
    FROM staff
    WHERE staff.company_id = p_company_id
  ),
  staff_departments AS (
    -- Get primary departments for staff with explicit column aliases
    SELECT 
      staff_dept.staff_id AS dept_staff_id,
      dept.name AS dept_name
    FROM staff_departments staff_dept
    JOIN departments dept ON staff_dept.department_id = dept.id
    WHERE staff_dept.is_primary = true
    AND staff_dept.staff_id IN (SELECT staff_member_id FROM staff_members)
  )
  SELECT 
    warning_letters.id AS warning_letter_id,
    warning_letters.staff_id,
    upper(warning_letters.warning_level::text),
    warning_letters.incident_date,
    warning_letters.description,
    warning_letters.improvement_plan,
    warning_letters.consequences,
    warning_letters.issued_date,
    warning_letters.show_cause_response,
    warning_letters.response_submitted_at,
    staff_members.staff_member_name,
    staff_departments.dept_name
  FROM warning_letters
  JOIN staff_members ON warning_letters.staff_id = staff_members.staff_member_id
  LEFT JOIN staff_departments ON warning_letters.staff_id = staff_departments.dept_staff_id
  WHERE staff_members.staff_company_id = p_company_id
  ORDER BY warning_letters.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

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
  USING (true);

CREATE POLICY "warning_letters_insert"
  ON warning_letters FOR INSERT
  WITH CHECK (true);

CREATE POLICY "warning_letters_update"
  ON warning_letters FOR UPDATE
  USING (true);

CREATE POLICY "warning_letters_delete"
  ON warning_letters FOR DELETE
  USING (true);