-- Add company_id column to employee_form_requests table
ALTER TABLE employee_form_requests
ADD COLUMN company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

-- Create index for better performance
CREATE INDEX idx_employee_form_requests_company 
ON employee_form_requests(company_id);

-- Update RLS policies to include company isolation
DROP POLICY IF EXISTS "employee_form_requests_select" ON employee_form_requests;
DROP POLICY IF EXISTS "employee_form_requests_insert" ON employee_form_requests;

CREATE POLICY "employee_form_requests_select"
  ON employee_form_requests FOR SELECT
  USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all requests
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see their company's requests
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "employee_form_requests_insert"
  ON employee_form_requests FOR INSERT
  WITH CHECK (
    company_id = (
      SELECT company_id FROM staff WHERE id = auth.uid()
    )
  );

-- Create function to get employee form requests for a company
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