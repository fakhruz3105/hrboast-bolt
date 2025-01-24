-- First drop existing function to avoid conflict
DROP FUNCTION IF EXISTS get_company_warning_letters(uuid);

-- Drop existing warning letter policies
DROP POLICY IF EXISTS "warning_letters_select" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_insert" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_update" ON warning_letters;
DROP POLICY IF EXISTS "warning_letters_delete" ON warning_letters;

-- Create improved RLS policies for warning letters
CREATE POLICY "warning_letters_select"
  ON warning_letters FOR SELECT
  USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all warning letters
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see warning letters for their company's staff
      EXISTS (
        SELECT 1 FROM staff s
        WHERE s.id = warning_letters.staff_id
        AND s.company_id = (
          SELECT company_id FROM staff WHERE id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "warning_letters_insert"
  ON warning_letters FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = warning_letters.staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "warning_letters_update"
  ON warning_letters FOR UPDATE
  USING (
    auth.role() = 'authenticated' AND
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
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM staff s
      WHERE s.id = warning_letters.staff_id
      AND s.company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

-- Create new function with proper return type
CREATE OR REPLACE FUNCTION get_company_warning_letters(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  warning_level warning_level,
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
  SELECT 
    wl.id,
    wl.staff_id,
    wl.warning_level,
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
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;