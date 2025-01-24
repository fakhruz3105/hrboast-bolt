-- Drop existing policies
DROP POLICY IF EXISTS "staff_select" ON staff;
DROP POLICY IF EXISTS "benefits_select" ON benefits;
DROP POLICY IF EXISTS "benefits_insert" ON benefits;
DROP POLICY IF EXISTS "benefits_update" ON benefits;
DROP POLICY IF EXISTS "benefits_delete" ON benefits;
DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;

-- Create simplified RLS policies
CREATE POLICY "staff_select"
  ON staff FOR SELECT
  USING (true);  -- Allow all authenticated users to read staff

CREATE POLICY "benefits_select"
  ON benefits FOR SELECT
  USING (true);  -- Allow all authenticated users to read benefits

CREATE POLICY "benefits_insert"
  ON benefits FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create benefits

CREATE POLICY "benefits_update"
  ON benefits FOR UPDATE
  USING (true);  -- Allow all authenticated users to update benefits

CREATE POLICY "benefits_delete"
  ON benefits FOR DELETE
  USING (true);  -- Allow all authenticated users to delete benefits

CREATE POLICY "evaluation_forms_select"
  ON evaluation_forms FOR SELECT
  USING (true);  -- Allow all authenticated users to read evaluations

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
  created_at timestamptz,
  updated_at timestamptz
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
    c.created_at,
    c.updated_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  WHERE c.id = p_company_id
  GROUP BY c.id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company staff details
CREATE OR REPLACE FUNCTION get_company_staff_details(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  phone_number text,
  department_name text,
  level_name text,
  status text,
  is_active boolean,
  join_date date
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    s.phone_number,
    d.name as department_name,
    sl.name as level_name,
    s.status::text,
    s.is_active,
    s.join_date
  FROM staff s
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  LEFT JOIN staff_levels_junction slj ON s.id = slj.staff_id AND slj.is_primary = true
  LEFT JOIN staff_levels sl ON slj.level_id = sl.id
  WHERE s.company_id = p_company_id
  ORDER BY s.name;
END;
$$ LANGUAGE plpgsql;