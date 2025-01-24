-- Drop existing function
DROP FUNCTION IF EXISTS create_warning_letter;

-- Create improved function with proper company_id handling
CREATE OR REPLACE FUNCTION create_warning_letter(
  p_staff_id uuid,
  p_warning_level text,
  p_incident_date date,
  p_description text,
  p_improvement_plan text,
  p_consequences text,
  p_issued_date date
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
  v_company_id uuid;
  v_staff_name text;
BEGIN
  -- Get company_id and staff name
  SELECT company_id, name INTO v_company_id, v_staff_name
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  -- Start transaction
  BEGIN
    -- Insert warning letter
    INSERT INTO warning_letters (
      staff_id,
      company_id,  -- Explicitly set company_id
      warning_level,
      incident_date,
      description,
      improvement_plan,
      consequences,
      issued_date
    ) VALUES (
      p_staff_id,
      v_company_id,  -- Use the retrieved company_id
      p_warning_level::warning_level,
      p_incident_date,
      p_description,
      p_improvement_plan,
      p_consequences,
      p_issued_date
    ) RETURNING id INTO v_letter_id;

    -- Create corresponding HR letter
    INSERT INTO hr_letters (
      staff_id,
      title,
      type,
      content,
      status,
      issued_date
    ) VALUES (
      p_staff_id,
      initcap(p_warning_level) || ' Warning Letter - ' || v_staff_name,
      'warning',
      jsonb_build_object(
        'warning_letter_id', v_letter_id,
        'warning_level', p_warning_level,
        'incident_date', p_incident_date,
        'description', p_description,
        'improvement_plan', p_improvement_plan,
        'consequences', p_consequences
      ),
      'pending',
      p_issued_date
    );

    -- Commit transaction
    RETURN v_letter_id;
  EXCEPTION WHEN OTHERS THEN
    -- Rollback on error
    RAISE;
  END;
END;
$$ LANGUAGE plpgsql;

-- Update get_company_warning_letters function to use company_id properly
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
    -- Get all staff for the company
    SELECT 
      s.id AS staff_member_id,
      s.name AS staff_member_name,
      s.company_id AS staff_company_id
    FROM staff s
    WHERE s.company_id = p_company_id
  ),
  staff_departments AS (
    -- Get primary departments
    SELECT 
      sd.staff_id AS dept_staff_id,
      d.name AS dept_name
    FROM staff_departments sd
    JOIN departments d ON sd.department_id = d.id
    WHERE sd.is_primary = true
    AND sd.staff_id IN (SELECT staff_member_id FROM staff_members)
  )
  SELECT 
    wl.id AS warning_letter_id,
    wl.staff_id,
    upper(wl.warning_level::text),
    wl.incident_date,
    wl.description,
    wl.improvement_plan,
    wl.consequences,
    wl.issued_date,
    wl.show_cause_response,
    wl.response_submitted_at,
    sm.staff_member_name,
    sd.dept_name
  FROM warning_letters wl
  JOIN staff_members sm ON wl.staff_id = sm.staff_member_id
  LEFT JOIN staff_departments sd ON wl.staff_id = sd.dept_staff_id
  WHERE wl.company_id = p_company_id  -- Use company_id from warning_letters
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Ensure all warning letters have company_id set
UPDATE warning_letters wl
SET company_id = s.company_id
FROM staff s
WHERE wl.staff_id = s.id
AND wl.company_id IS NULL;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_warning_letters_company_staff 
ON warning_letters(company_id, staff_id);

CREATE INDEX IF NOT EXISTS idx_warning_letters_issued_date 
ON warning_letters(issued_date);