/*
  # Add dummy staff interview records

  1. Changes
    - Insert 5 dummy staff interview records with different statuses and departments
*/

-- Insert dummy staff interview records
INSERT INTO staff_interviews (
  staff_name,
  email,
  department_id,
  level_id,
  form_link,
  status,
  expires_at
)
SELECT
  name,
  email,
  department_id,
  level_id,
  form_link,
  status,
  expires_at
FROM (
  VALUES
    (
      'John Smith',
      'john.smith@example.com',
      (SELECT id FROM departments WHERE name = 'Engineering'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '/staff-form/11111111-1111-1111-1111-111111111111',
      'pending'::staff_interview_status,
      (NOW() + INTERVAL '7 days')
    ),
    (
      'Maria Garcia',
      'maria.garcia@example.com',
      (SELECT id FROM departments WHERE name = 'Marketing'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '/staff-form/22222222-2222-2222-2222-222222222222',
      'completed'::staff_interview_status,
      (NOW() + INTERVAL '7 days')
    ),
    (
      'Alex Wong',
      'alex.wong@example.com',
      (SELECT id FROM departments WHERE name = 'Finance'),
      (SELECT id FROM staff_levels WHERE name = 'HOD/Manager'),
      '/staff-form/33333333-3333-3333-3333-333333333333',
      'pending'::staff_interview_status,
      (NOW() + INTERVAL '7 days')
    ),
    (
      'Sarah Johnson',
      'sarah.johnson@example.com',
      (SELECT id FROM departments WHERE name = 'Human Resources'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '/staff-form/44444444-4444-4444-4444-444444444444',
      'expired'::staff_interview_status,
      (NOW() - INTERVAL '1 day')
    ),
    (
      'Michael Lee',
      'michael.lee@example.com',
      (SELECT id FROM departments WHERE name = 'Sales'),
      (SELECT id FROM staff_levels WHERE name = 'Staff'),
      '/staff-form/55555555-5555-5555-5555-555555555555',
      'pending'::staff_interview_status,
      (NOW() + INTERVAL '7 days')
    )
) AS dummy_data(
  name,
  email,
  department_id,
  level_id,
  form_link,
  status,
  expires_at
)
WHERE NOT EXISTS (
  SELECT 1 FROM staff_interviews WHERE email = dummy_data.email
);