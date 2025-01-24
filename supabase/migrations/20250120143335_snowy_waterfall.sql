-- Create function to handle warning level uppercase conversion
CREATE OR REPLACE FUNCTION upper(warning_level warning_level)
RETURNS text AS $$
BEGIN
  RETURN upper(warning_level::text);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Update get_company_warning_letters function to use the new upper function
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
    upper(wl.warning_level),  -- Use our new upper function
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