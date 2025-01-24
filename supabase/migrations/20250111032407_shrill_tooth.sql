-- Drop existing function
DROP FUNCTION IF EXISTS create_company;

-- Create improved company creation function that also creates staff
CREATE OR REPLACE FUNCTION create_company(
  p_name text,
  p_email text,
  p_phone text,
  p_address text
) RETURNS uuid AS $$
DECLARE
  v_company_id uuid;
  v_admin_level_id uuid;
  v_admin_role_id uuid;
BEGIN
  -- Create company
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at,
    is_active
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days',
    true
  ) RETURNING id INTO v_company_id;

  -- Get admin level ID
  SELECT id INTO v_admin_level_id
  FROM staff_levels
  WHERE name = 'Director'
  LIMIT 1;

  -- Get admin role ID
  SELECT id INTO v_admin_role_id
  FROM role_mappings
  WHERE role = 'admin'
  LIMIT 1;

  -- Create admin staff member
  INSERT INTO staff (
    name,
    email,
    phone_number,
    company_id,
    role_id,
    join_date,
    status,
    is_active,
    password_hash
  ) VALUES (
    p_name || ' Admin', -- Default admin name
    p_email,
    p_phone,
    v_company_id,
    v_admin_role_id,
    CURRENT_DATE,
    'permanent',
    true,
    'default123' -- Default password that should be changed on first login
  );

  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;

-- Add password_hash column to staff if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'staff' 
    AND column_name = 'password_hash'
  ) THEN
    ALTER TABLE staff
    ADD COLUMN password_hash text;
  END IF;
END $$;

-- Update password update function
CREATE OR REPLACE FUNCTION update_staff_password(
  p_email text,
  p_password text
)
RETURNS void AS $$
BEGIN
  -- Verify staff exists
  IF NOT EXISTS (
    SELECT 1 FROM staff WHERE email = p_email
  ) THEN
    RAISE EXCEPTION 'Staff member not found';
  END IF;

  -- Update the staff password
  UPDATE staff
  SET 
    password_hash = p_password,
    updated_at = now()
  WHERE email = p_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;