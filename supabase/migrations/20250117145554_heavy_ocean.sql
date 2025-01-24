-- First ensure we have the correct role mapping for super_admin
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'super_admin'
FROM staff_levels
WHERE name = 'Director'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'super_admin';

-- Create or update super admin user
DO $$
DECLARE
  v_director_id uuid;
  v_role_id uuid;
BEGIN
  -- Get Director level ID
  SELECT id INTO v_director_id
  FROM staff_levels
  WHERE name = 'Director';

  -- Get super_admin role ID
  SELECT id INTO v_role_id
  FROM role_mappings
  WHERE staff_level_id = v_director_id;

  -- Create or update super admin user
  INSERT INTO staff (
    name,
    email,
    phone_number,
    role_id,
    join_date,
    status,
    is_active
  ) VALUES (
    'Super Admin',
    'super.admin@example.com',
    '+60123456789',
    v_role_id,
    CURRENT_DATE,
    'permanent',
    true
  )
  ON CONFLICT (email) DO UPDATE
  SET 
    role_id = EXCLUDED.role_id,
    is_active = true;
END $$;