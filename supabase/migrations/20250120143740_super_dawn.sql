-- Drop existing function
DROP FUNCTION IF EXISTS get_company_warning_letters;

-- Create improved function with proper company isolation
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
  -- Return warning letters with proper company isolation
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
  JOIN staff s ON wl.staff_id = s.id  -- Join with staff
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE s.company_id = p_company_id  -- Filter by staff's company_id
  ORDER BY wl.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Update any existing warning letters to have the correct company_id
UPDATE warning_letters wl
SET company_id = s.company_id
FROM staff s
WHERE wl.staff_id = s.id
AND wl.company_id IS NULL;

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_warning_letters_company 
ON warning_letters(company_id);

-- Create index for staff company lookup
CREATE INDEX IF NOT EXISTS idx_staff_company 
ON staff(company_id);