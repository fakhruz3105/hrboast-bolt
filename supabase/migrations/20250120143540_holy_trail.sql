-- First update any existing warning letters to have the correct company_id
UPDATE warning_letters wl
SET company_id = s.company_id
FROM staff s
WHERE wl.staff_id = s.id
AND wl.company_id IS NULL;

-- Make company_id NOT NULL
ALTER TABLE warning_letters 
ALTER COLUMN company_id SET NOT NULL;

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
BEGIN
  -- Get company_id from staff
  SELECT company_id INTO v_company_id
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

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

  -- Create HR letter for the warning
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status,
    issued_date
  ) VALUES (
    p_staff_id,
    p_warning_level || ' WARNING LETTER',
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

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Update get_company_warning_letters function to use company_id properly
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
  WHERE wl.company_id = p_company_id  -- Use company_id from warning_letters table
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;