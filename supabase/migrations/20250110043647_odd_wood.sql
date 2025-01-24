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

-- Create function to get all staff departments
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

-- Create function to get staff details with departments
CREATE OR REPLACE FUNCTION get_staff_details(p_staff_id uuid)
RETURNS TABLE (
  staff_id uuid,
  staff_name text,
  primary_department_name text,
  primary_level_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id as staff_id,
    s.name as staff_name,
    d.name as primary_department_name,
    sl.name as primary_level_name
  FROM staff s
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = true
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.id = p_staff_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get evaluation details
CREATE OR REPLACE FUNCTION get_evaluation_details(p_evaluation_id uuid)
RETURNS TABLE (
  evaluation_id uuid,
  staff_name text,
  department_name text,
  manager_name text,
  status text,
  percentage_score numeric
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    er.id as evaluation_id,
    s.name as staff_name,
    d.name as department_name,
    m.name as manager_name,
    er.status::text,
    er.percentage_score
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff m ON er.manager_id = m.id
  WHERE er.id = p_evaluation_id;
END;
$$ LANGUAGE plpgsql;