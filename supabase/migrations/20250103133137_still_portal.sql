/*
  # Set up admin role and user

  1. Changes
    - Ensures admin user exists with Director level and admin role
    - Updates role mappings for admin access
    - Sets proper department and permissions

  2. Security
    - Maintains RLS policies
    - Ensures admin has highest level access
*/

-- First ensure we have the correct role mapping for admin
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'admin'
FROM staff_levels
WHERE name = 'Director'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'admin';

-- Create or update admin user in staff table
DO $$
DECLARE
  v_department_id uuid;
  v_level_id uuid;
  v_role_id uuid;
BEGIN
  -- Get Executive department ID
  SELECT id INTO v_department_id
  FROM departments
  WHERE name = 'Executive'
  LIMIT 1;

  -- Get Director level ID
  SELECT id INTO v_level_id
  FROM staff_levels
  WHERE name = 'Director'
  LIMIT 1;

  -- Get admin role ID
  SELECT id INTO v_role_id
  FROM role_mappings
  WHERE role = 'admin'
  LIMIT 1;

  -- Create or update admin user
  INSERT INTO staff (
    name,
    email,
    phone_number,
    department_id,
    level_id,
    role_id,
    join_date,
    status
  ) VALUES (
    'System Admin',
    'admin@example.com',
    '+60123456789',
    v_department_id,
    v_level_id,
    v_role_id,
    CURRENT_DATE,
    'permanent'
  )
  ON CONFLICT (email) DO UPDATE
  SET
    level_id = EXCLUDED.level_id,
    role_id = EXCLUDED.role_id,
    department_id = EXCLUDED.department_id,
    status = EXCLUDED.status;
END $$;