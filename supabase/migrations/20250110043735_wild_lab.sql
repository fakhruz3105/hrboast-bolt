-- Create function to get staff's primary department
CREATE OR REPLACE FUNCTION get_staff_primary_department(p_staff_id uuid)
RETURNS TABLE (
  department_id uuid,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id as department_id,
    d.name as department_name
  FROM staff_departments sd
  JOIN departments d ON d.id = sd.department_id
  WHERE sd.staff_id = p_staff_id
  AND sd.is_primary = true;
END;
$$ LANGUAGE plpgsql;

-- Create function to get staff's departments
CREATE OR REPLACE FUNCTION get_staff_departments(p_staff_id uuid)
RETURNS TABLE (
  department_id uuid,
  department_name text,
  is_primary boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id as department_id,
    d.name as department_name,
    sd.is_primary
  FROM staff_departments sd
  JOIN departments d ON d.id = sd.department_id
  WHERE sd.staff_id = p_staff_id
  ORDER BY sd.is_primary DESC, d.name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get warning letter details
CREATE OR REPLACE FUNCTION get_warning_letter_details(p_letter_id uuid)
RETURNS TABLE (
  letter_id uuid,
  staff_name text,
  department_name text,
  warning_level text,
  incident_date date,
  description text,
  improvement_plan text,
  consequences text,
  issued_date date,
  show_cause_response text,
  response_submitted_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    wl.id as letter_id,
    s.name as staff_name,
    d.name as department_name,
    wl.warning_level::text,
    wl.incident_date,
    wl.description,
    wl.improvement_plan,
    wl.consequences,
    wl.issued_date,
    wl.show_cause_response,
    wl.response_submitted_at
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE wl.id = p_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get exit interview details
CREATE OR REPLACE FUNCTION get_exit_interview_details(p_letter_id uuid)
RETURNS TABLE (
  letter_id uuid,
  staff_name text,
  department_name text,
  content jsonb,
  status text,
  issued_date timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id as letter_id,
    s.name as staff_name,
    d.name as department_name,
    l.content,
    l.status::text,
    l.issued_date
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.id = p_letter_id
  AND l.type = 'interview'
  AND l.content->>'type' = 'exit';
END;
$$ LANGUAGE plpgsql;

-- Create function to get staff letters
CREATE OR REPLACE FUNCTION get_staff_letters(p_staff_id uuid)
RETURNS TABLE (
  letter_id uuid,
  title text,
  type text,
  content jsonb,
  status text,
  issued_date timestamptz,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id as letter_id,
    l.title,
    l.type::text,
    l.content,
    l.status::text,
    l.issued_date,
    d.name as department_name
  FROM hr_letters l
  LEFT JOIN staff_departments sd ON p_staff_id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.staff_id = p_staff_id
  ORDER BY l.issued_date DESC;
END;
$$ LANGUAGE plpgsql;