-- Drop existing function
DROP FUNCTION IF EXISTS create_company;

-- Create improved company creation function that sets default password
CREATE OR REPLACE FUNCTION create_company(
  p_name text,
  p_email text,
  p_phone text,
  p_address text
) RETURNS uuid AS $$
DECLARE
  v_company_id uuid;
BEGIN
  -- Create company with default password
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at,
    is_active,
    password_hash
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days',
    true,
    'default123' -- Default password that should be changed on first login
  ) RETURNING id INTO v_company_id;

  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to verify company login
CREATE OR REPLACE FUNCTION verify_company_login(
  p_email text,
  p_password text
) RETURNS TABLE (
  id uuid,
  name text,
  email text,
  is_valid boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    CASE 
      WHEN c.password_hash = p_password AND c.is_active = true THEN true
      ELSE false
    END as is_valid
  FROM companies c
  WHERE c.email = p_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;