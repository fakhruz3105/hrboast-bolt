-- First ensure warning_level is handled correctly
CREATE OR REPLACE FUNCTION format_warning_level(p_level warning_level)
RETURNS text AS $$
BEGIN
  RETURN CASE p_level
    WHEN 'first' THEN 'FIRST'
    WHEN 'second' THEN 'SECOND'
    WHEN 'final' THEN 'FINAL'
  END;
END;
$$ LANGUAGE plpgsql;

-- Create function to get warning letters for a company
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

-- Create function to create warning letter
CREATE OR REPLACE FUNCTION create_warning_letter(
  p_staff_id uuid,
  p_warning_level warning_level,
  p_incident_date date,
  p_description text,
  p_improvement_plan text,
  p_consequences text,
  p_issued_date date
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
BEGIN
  -- Insert warning letter
  INSERT INTO warning_letters (
    staff_id,
    warning_level,
    incident_date,
    description,
    improvement_plan,
    consequences,
    issued_date
  ) VALUES (
    p_staff_id,
    p_warning_level,
    p_incident_date,
    p_description,
    p_improvement_plan,
    p_consequences,
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;