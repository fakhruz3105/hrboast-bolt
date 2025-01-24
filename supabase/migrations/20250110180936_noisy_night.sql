-- First modify the role_mappings table to accept super_admin role
DO $$ 
BEGIN
  -- Drop the existing check constraint if it exists
  ALTER TABLE role_mappings 
  DROP CONSTRAINT IF EXISTS role_mappings_role_check;

  -- Add new check constraint with super_admin role
  ALTER TABLE role_mappings
  ADD CONSTRAINT role_mappings_role_check 
  CHECK (role IN ('admin', 'hr', 'staff', 'super_admin'));
END $$;

-- Add super_admin role to role_mappings if not exists
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'super_admin'
FROM staff_levels
WHERE name = 'Director'
  AND NOT EXISTS (
    SELECT 1 FROM role_mappings 
    WHERE staff_level_id = staff_levels.id 
    AND role = 'super_admin'
  )
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'super_admin';

-- Add company_id to staff table if not exists
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'staff' 
    AND column_name = 'company_id'
  ) THEN
    ALTER TABLE staff
    ADD COLUMN company_id uuid REFERENCES companies(id) ON DELETE CASCADE;
    
    CREATE INDEX IF NOT EXISTS idx_staff_company ON staff(company_id);
  END IF;
END $$;

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

-- Drop existing policies
DROP POLICY IF EXISTS "companies_select" ON companies;
DROP POLICY IF EXISTS "companies_insert" ON companies;
DROP POLICY IF EXISTS "companies_update" ON companies;
DROP POLICY IF EXISTS "staff_select" ON staff;

-- Create new RLS policies
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

CREATE POLICY "companies_insert" ON companies
  FOR INSERT WITH CHECK (true);

CREATE POLICY "companies_update" ON companies
  FOR UPDATE USING (
    auth.role() = 'authenticated' AND
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role = 'super_admin'
    )
  );

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

-- Create function to get company details
CREATE OR REPLACE FUNCTION get_company_details(p_company_id uuid)
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

-- Create function to get company staff
CREATE OR REPLACE FUNCTION get_company_staff(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  department_name text,
  level_name text,
  status text,
  is_active boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    d.name as department_name,
    sl.name as level_name,
    s.status::text,
    s.is_active
  FROM staff s
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = true
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.company_id = p_company_id
  ORDER BY s.name;
END;
$$ LANGUAGE plpgsql;