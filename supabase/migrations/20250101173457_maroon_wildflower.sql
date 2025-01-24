/*
  # Add Dummy Staff Data

  1. Changes
    - Insert 5 dummy staff members with realistic data
    - Each staff member has different departments and levels
    - Mix of different statuses (permanent, probation)
    - Fixed date casting for join_date column
*/

-- Insert dummy staff data
INSERT INTO staff (name, phone_number, email, department_id, level_id, join_date, status)
SELECT
  name,
  phone_number,
  email,
  department_id,
  level_id,
  join_date::date,
  status
FROM (
  VALUES
    (
      'Sarah Chen',
      '+60123456789',
      'sarah.chen@company.com',
      (SELECT id FROM departments WHERE name = 'Engineering'),
      (SELECT id FROM staff_levels WHERE name = 'HOD/Manager'),
      '2023-01-15',
      'permanent'::staff_status
    ),
    (
      'Ahmad Ismail',
      '+60167891234',
      'ahmad.ismail@company.com',
      (SELECT id FROM departments WHERE name = 'Marketing'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '2023-06-01',
      'probation'::staff_status
    ),
    (
      'Raj Patel',
      '+60198765432',
      'raj.patel@company.com',
      (SELECT id FROM departments WHERE name = 'Finance'),
      (SELECT id FROM staff_levels WHERE name = 'HOD/Manager'),
      '2022-11-01',
      'permanent'::staff_status
    ),
    (
      'Lisa Wong',
      '+60145678912',
      'lisa.wong@company.com',
      (SELECT id FROM departments WHERE name = 'Human Resources'),
      (SELECT id FROM staff_levels WHERE name = 'HR'),
      '2023-03-15',
      'permanent'::staff_status
    ),
    (
      'David Tan',
      '+60134567891',
      'david.tan@company.com',
      (SELECT id FROM departments WHERE name = 'Sales'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '2023-09-01',
      'probation'::staff_status
    )
) AS dummy_data(name, phone_number, email, department_id, level_id, join_date, status)
WHERE NOT EXISTS (
  SELECT 1 FROM staff WHERE email = dummy_data.email
);