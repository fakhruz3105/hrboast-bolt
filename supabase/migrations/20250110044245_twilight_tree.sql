-- Drop existing functions first
DROP FUNCTION IF EXISTS get_staff_details(uuid);
DROP FUNCTION IF EXISTS get_hr_letter_details(uuid);
DROP FUNCTION IF EXISTS get_evaluation_response_details(uuid);

-- Create function to get staff details with departments and levels
CREATE OR REPLACE FUNCTION get_staff_details(p_staff_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  primary_department text,
  primary_level text,
  other_departments text[],
  other_levels text[],
  join_date date,
  status text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    pd.name as primary_department,
    pl.name as primary_level,
    ARRAY_AGG(DISTINCT d.name) FILTER (WHERE sd.is_primary = false) as other_departments,
    ARRAY_AGG(DISTINCT sl.name) FILTER (WHERE slj.is_primary = false) as other_levels,
    s.join_date::date,
    s.status::text
  FROM staff s
  -- Get primary department
  LEFT JOIN LATERAL (
    SELECT d.name, d.id
    FROM staff_departments sd
    JOIN departments d ON d.id = sd.department_id
    WHERE sd.staff_id = s.id AND sd.is_primary = true
    LIMIT 1
  ) pd ON true
  -- Get primary level
  LEFT JOIN LATERAL (
    SELECT sl.name, sl.id
    FROM staff_levels_junction slj
    JOIN staff_levels sl ON sl.id = slj.level_id
    WHERE slj.staff_id = s.id AND slj.is_primary = true
    LIMIT 1
  ) pl ON true
  -- Get other departments
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = false
  LEFT JOIN departments d ON sd.department_id = d.id
  -- Get other levels
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = false
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.id = p_staff_id
  GROUP BY s.id, s.name, s.email, pd.name, pl.name, s.join_date, s.status;
END;
$$ LANGUAGE plpgsql;

-- Create function to get HR letter details
CREATE OR REPLACE FUNCTION get_hr_letter_details(p_letter_id uuid)
RETURNS TABLE (
  id uuid,
  title text,
  type text,
  content jsonb,
  status text,
  staff_name text,
  department_name text,
  issued_date timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.title,
    l.type::text,
    l.content,
    l.status::text,
    s.name as staff_name,
    pd.name as department_name,
    l.issued_date
  FROM hr_letters l
  LEFT JOIN staff s ON l.staff_id = s.id
  LEFT JOIN LATERAL (
    SELECT d.name
    FROM staff_departments sd
    JOIN departments d ON d.id = sd.department_id
    WHERE sd.staff_id = s.id AND sd.is_primary = true
    LIMIT 1
  ) pd ON true
  WHERE l.id = p_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get evaluation response details
CREATE OR REPLACE FUNCTION get_evaluation_response_details(p_response_id uuid)
RETURNS TABLE (
  id uuid,
  staff_name text,
  department_name text,
  manager_name text,
  status text,
  percentage_score numeric,
  submitted_at timestamptz,
  completed_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    er.id,
    s.name as staff_name,
    pd.name as department_name,
    m.name as manager_name,
    er.status::text,
    er.percentage_score,
    er.submitted_at,
    er.completed_at
  FROM evaluation_responses er
  LEFT JOIN staff s ON er.staff_id = s.id
  LEFT JOIN staff m ON er.manager_id = m.id
  LEFT JOIN LATERAL (
    SELECT d.name
    FROM staff_departments sd
    JOIN departments d ON d.id = sd.department_id
    WHERE sd.staff_id = s.id AND sd.is_primary = true
    LIMIT 1
  ) pd ON true
  WHERE er.id = p_response_id;
END;
$$ LANGUAGE plpgsql;