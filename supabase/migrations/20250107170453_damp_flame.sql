-- Insert staff user
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
  'Demo Staff',
  'staff@example.com',
  '+60123456789',
  d.id as department_id,
  sl.id as level_id,
  rm.id as role_id,
  CURRENT_DATE,
  'permanent'
FROM departments d
CROSS JOIN staff_levels sl
JOIN role_mappings rm ON rm.staff_level_id = sl.id
WHERE d.name = 'Engineering'
  AND sl.name = 'Staff'
  AND rm.role = 'staff'
ON CONFLICT (email) DO UPDATE
SET
  level_id = EXCLUDED.level_id,
  role_id = EXCLUDED.role_id,
  department_id = EXCLUDED.department_id,
  status = EXCLUDED.status;