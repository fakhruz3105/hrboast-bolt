-- Drop existing policies
DROP POLICY IF EXISTS "staff_select" ON staff;
DROP POLICY IF EXISTS "benefits_select" ON benefits;
DROP POLICY IF EXISTS "benefits_insert" ON benefits;
DROP POLICY IF EXISTS "benefits_update" ON benefits;
DROP POLICY IF EXISTS "benefits_delete" ON benefits;
DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;

-- Create simplified RLS policies
CREATE POLICY "staff_select_new"
  ON staff FOR SELECT
  USING (true);  -- Allow all authenticated users to read staff

CREATE POLICY "benefits_select_new"
  ON benefits FOR SELECT
  USING (true);  -- Allow all authenticated users to read benefits

CREATE POLICY "benefits_insert_new"
  ON benefits FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create benefits

CREATE POLICY "benefits_update_new"
  ON benefits FOR UPDATE
  USING (true);  -- Allow all authenticated users to update benefits

CREATE POLICY "benefits_delete_new"
  ON benefits FOR DELETE
  USING (true);  -- Allow all authenticated users to delete benefits

CREATE POLICY "evaluation_forms_select_new"
  ON evaluation_forms FOR SELECT
  USING (true);  -- Allow all authenticated users to read evaluations

-- Create function to get company details
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