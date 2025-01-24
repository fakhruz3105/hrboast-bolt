-- First drop existing functions to avoid conflicts
DROP FUNCTION IF EXISTS get_company_data(text, uuid);
DROP FUNCTION IF EXISTS get_company_details(uuid);

-- Add company_id to all relevant tables if not exists
ALTER TABLE benefits 
ADD COLUMN IF NOT EXISTS company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

ALTER TABLE evaluation_forms 
ADD COLUMN IF NOT EXISTS company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_benefits_company ON benefits(company_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_forms_company ON evaluation_forms(company_id);

-- Update RLS policies to use company_id
DROP POLICY IF EXISTS "staff_select" ON staff;
CREATE POLICY "staff_select" ON staff
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all staff
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see staff from their company
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "benefits_select" ON benefits;
CREATE POLICY "benefits_select" ON benefits
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all benefits
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see their company's benefits
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;
CREATE POLICY "evaluation_forms_select" ON evaluation_forms
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all evaluations
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see their company's evaluations
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

-- Create function to get company data with unique name
CREATE OR REPLACE FUNCTION get_company_table_data(
  p_table_name text,
  p_company_id uuid
)
RETURNS SETOF json AS $$
BEGIN
  RETURN QUERY EXECUTE format(
    'SELECT row_to_json(t) FROM (SELECT * FROM %I WHERE company_id = %L) t',
    p_table_name,
    p_company_id
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company details with unique name
CREATE OR REPLACE FUNCTION get_company_info(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  phone text,
  address text,
  subscription_status text,
  trial_ends_at timestamptz,
  is_active boolean,
  staff_count bigint,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.address,
    c.subscription_status,
    c.trial_ends_at,
    c.is_active,
    COUNT(s.id) as staff_count,
    c.created_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  WHERE c.id = p_company_id
  GROUP BY c.id;
END;
$$ LANGUAGE plpgsql;