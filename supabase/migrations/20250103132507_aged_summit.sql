/*
  # Setup Admin User

  1. New Data
    - Create admin user in staff table
    - Ensure proper role mapping
  
  2. Changes
    - Add admin user with proper department and level
    - Link admin user to role mapping
*/

-- First ensure we have the correct role mapping for admin
INSERT INTO role_mappings (staff_level_id, role)
SELECT id, 'admin'
FROM staff_levels
WHERE name = 'Director'
ON CONFLICT (staff_level_id) DO UPDATE
SET role = 'admin';

-- Create admin user in staff table
INSERT INTO staff (
  name,
  email,
  phone_number,
  department_id,
  level_id,
  role_id,
  join_date,
  status
)
SELECT
  'System Admin',
  'admin@example.com',
  '+60123456789',
  departments.id,
  staff_levels.id,
  role_mappings.id,
  CURRENT_DATE,
  'permanent'
FROM departments
CROSS JOIN staff_levels
JOIN role_mappings ON role_mappings.staff_level_id = staff_levels.id
WHERE departments.name = 'Executive'
  AND staff_levels.name = 'Director'
  AND role_mappings.role = 'admin'
ON CONFLICT (email) DO UPDATE
SET
  level_id = EXCLUDED.level_id,
  role_id = EXCLUDED.role_id;