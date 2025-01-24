-- First modify the role_mappings table to accept super_admin role
ALTER TABLE role_mappings 
DROP CONSTRAINT IF EXISTS role_mappings_role_check;

ALTER TABLE role_mappings
ADD CONSTRAINT role_mappings_role_check 
CHECK (role IN ('admin', 'hr', 'staff', 'super_admin'));

-- Create companies table
CREATE TABLE companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text,
  address text,
  subscription_status text NOT NULL DEFAULT 'trial',
  trial_ends_at timestamptz,
  is_active boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Add company_id to staff table
ALTER TABLE staff
ADD COLUMN company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

-- Create index for better performance
CREATE INDEX idx_staff_company ON staff(company_id);

-- Add super_admin role to role_mappings
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'super_admin'
FROM staff_levels
WHERE name = 'Director'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'super_admin';

-- Create function to create new company
CREATE OR REPLACE FUNCTION create_company(
  p_name text,
  p_email text,
  p_phone text,
  p_address text
) RETURNS uuid AS $$
DECLARE
  v_company_id uuid;
BEGIN
  -- Create company
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days'
  ) RETURNING id INTO v_company_id;

  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to activate company
CREATE OR REPLACE FUNCTION activate_company(p_company_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE companies
  SET 
    is_active = true,
    subscription_status = 'active',
    updated_at = now()
  WHERE id = p_company_id;
END;
$$ LANGUAGE plpgsql;

-- Add RLS policies
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "companies_select" ON companies
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all companies
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see their own company
      EXISTS (
        SELECT 1 FROM staff s
        WHERE s.id = auth.uid() AND s.company_id = companies.id
      )
    )
  );

-- Update existing staff policies to include company isolation
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