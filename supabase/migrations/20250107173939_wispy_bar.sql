-- First ensure we have the correct role mappings
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'admin'
FROM staff_levels
WHERE name = 'Director'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'admin';

INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'staff'
FROM staff_levels
WHERE name = 'Staff'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'staff';

-- Create or update admin user
DO $$
DECLARE
  v_admin_dept_id uuid;
  v_admin_level_id uuid;
  v_admin_role_id uuid;
BEGIN
  -- Get Executive department ID
  SELECT id INTO v_admin_dept_id
  FROM departments
  WHERE name = 'Executive'
  LIMIT 1;

  -- Get Director level ID
  SELECT id INTO v_admin_level_id
  FROM staff_levels
  WHERE name = 'Director'
  LIMIT 1;

  -- Get admin role ID
  SELECT id INTO v_admin_role_id
  FROM role_mappings
  WHERE role = 'admin'
  LIMIT 1;

  -- Create or update admin staff record
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
    v_admin_dept_id,
    v_admin_level_id,
    v_admin_role_id,
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

-- Create or update staff user
DO $$
DECLARE
  v_staff_dept_id uuid;
  v_staff_level_id uuid;
  v_staff_role_id uuid;
BEGIN
  -- Get Engineering department ID
  SELECT id INTO v_staff_dept_id
  FROM departments
  WHERE name = 'Engineering'
  LIMIT 1;

  -- Get Staff level ID
  SELECT id INTO v_staff_level_id
  FROM staff_levels
  WHERE name = 'Staff'
  LIMIT 1;

  -- Get staff role ID
  SELECT id INTO v_staff_role_id
  FROM role_mappings
  WHERE role = 'staff'
  LIMIT 1;

  -- Create or update staff record
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
    'Demo Staff',
    'staff@example.com',
    '+60123456789',
    v_staff_dept_id,
    v_staff_level_id,
    v_staff_role_id,
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