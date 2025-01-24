-- First drop existing function to avoid conflict
DROP FUNCTION IF EXISTS get_company_warning_letters(uuid);

-- Drop existing warning letter policies
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'warning_letters' AND policyname = 'warning_letters_select'
  ) THEN
    DROP POLICY "warning_letters_select" ON warning_letters;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'warning_letters' AND policyname = 'warning_letters_insert'
  ) THEN
    DROP POLICY "warning_letters_insert" ON warning_letters;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'warning_letters' AND policyname = 'warning_letters_update'
  ) THEN
    DROP POLICY "warning_letters_update" ON warning_letters;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'warning_letters' AND policyname = 'warning_letters_delete'
  ) THEN
    DROP POLICY "warning_letters_delete" ON warning_letters;
  END IF;
END $$;

-- Create improved RLS policies for warning letters
CREATE POLICY "warning_letters_select_policy"
  ON warning_letters FOR SELECT
  USING (true);  -- Allow all authenticated users to read warning letters

CREATE POLICY "warning_letters_insert_policy"
  ON warning_letters FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create warning letters

CREATE POLICY "warning_letters_update_policy"
  ON warning_letters FOR UPDATE
  USING (true);  -- Allow all authenticated users to update warning letters

CREATE POLICY "warning_letters_delete_policy"
  ON warning_letters FOR DELETE
  USING (true);  -- Allow all authenticated users to delete warning letters

-- Create new function with proper return type
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
  SELECT 
    wl.id,
    wl.staff_id,
    wl.warning_level::text,
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