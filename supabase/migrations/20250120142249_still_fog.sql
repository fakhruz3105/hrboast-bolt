-- Drop existing function
DROP FUNCTION IF EXISTS create_warning_letter;

-- Create improved function with proper enum handling and validation
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
  v_warning_level warning_level;
BEGIN
  -- Validate warning level
  IF p_warning_level NOT IN ('first', 'second', 'final') THEN
    RAISE EXCEPTION 'Invalid warning level. Must be one of: first, second, final';
  END IF;

  -- Get company_id from staff
  SELECT company_id INTO v_company_id
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  -- Cast warning level safely
  v_warning_level := p_warning_level::warning_level;

  -- Insert warning letter
  INSERT INTO warning_letters (
    staff_id,
    company_id,
    warning_level,
    incident_date,
    description,
    improvement_plan,
    consequences,
    issued_date
  ) VALUES (
    p_staff_id,
    v_company_id,
    v_warning_level,
    p_incident_date,
    p_description,
    p_improvement_plan,
    p_consequences,
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Update get_company_warning_letters function to handle enum casting properly
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
  WHERE wl.company_id = p_company_id
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;