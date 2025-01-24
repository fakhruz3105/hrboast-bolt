-- Drop existing policies if they exist
DROP POLICY IF EXISTS "employee_form_requests_select" ON employee_form_requests;
DROP POLICY IF EXISTS "employee_form_requests_insert" ON employee_form_requests;
DROP POLICY IF EXISTS "employee_form_requests_update" ON employee_form_requests;
DROP POLICY IF EXISTS "employee_form_requests_delete" ON employee_form_requests;

-- Create new RLS policies
CREATE POLICY "employee_form_requests_select"
  ON employee_form_requests FOR SELECT
  USING (true);  -- Allow all authenticated users to read

CREATE POLICY "employee_form_requests_insert"
  ON employee_form_requests FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to insert

CREATE POLICY "employee_form_requests_update"
  ON employee_form_requests FOR UPDATE
  USING (true);  -- Allow all authenticated users to update

CREATE POLICY "employee_form_requests_delete"
  ON employee_form_requests FOR DELETE
  USING (true);  -- Allow all authenticated users to delete

-- Create function to get company employee form requests
CREATE OR REPLACE FUNCTION get_company_employee_form_requests(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_name text,
  email text,
  phone_number text,
  department_name text,
  level_name text,
  status text,
  form_link text,
  created_at timestamptz,
  expires_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    efr.id,
    efr.staff_name,
    efr.email,
    efr.phone_number,
    d.name as department_name,
    sl.name as level_name,
    efr.status,
    efr.form_link,
    efr.created_at,
    efr.expires_at
  FROM employee_form_requests efr
  LEFT JOIN departments d ON efr.department_id = d.id
  LEFT JOIN staff_levels sl ON efr.level_id = sl.id
  WHERE efr.company_id = p_company_id
  ORDER BY efr.created_at DESC;
END;
$$ LANGUAGE plpgsql;