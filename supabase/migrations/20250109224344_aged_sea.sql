-- First ensure we have the correct role mappings
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'staff'
FROM staff_levels
WHERE name = 'Staff'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'staff';

-- Create or update staff user
DO $$
DECLARE
  v_department_id uuid;
  v_level_id uuid;
  v_role_id uuid;
BEGIN
  -- Get Engineering department ID
  SELECT id INTO v_department_id
  FROM departments
  WHERE name = 'Engineering'
  LIMIT 1;

  -- Get Staff level ID
  SELECT id INTO v_level_id
  FROM staff_levels
  WHERE name = 'Staff'
  LIMIT 1;

  -- Get staff role ID
  SELECT id INTO v_role_id
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