-- Drop existing function if it exists
DROP FUNCTION IF EXISTS get_company_details;

-- Create function to get all companies with staff count
CREATE OR REPLACE FUNCTION get_all_companies()
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
  GROUP BY c.id
  ORDER BY c.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Recreate get_company_details for single company
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