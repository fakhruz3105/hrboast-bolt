-- First handle any existing references to departments
DO $$
BEGIN
  -- Update employee form requests to use NULL department
  UPDATE employee_form_requests
  SET department_id = NULL
  WHERE department_id IN (SELECT id FROM departments);

  -- Remove existing department associations
  DELETE FROM staff_departments;
  
  -- Now we can safely delete existing departments
  DELETE FROM departments;
END $$;

-- Insert new departments with consistent naming
INSERT INTO departments (name, description)
VALUES 
  ('C-Suite Department', 'Executive leadership and strategic decision making'),
  ('Management Department', 'Organizational management and team leadership'),
  ('Finance Department', 'Financial planning, accounting, and reporting'),
  ('HR Department', 'Human resources management and employee relations'),
  ('Tour Department', 'Tour planning and management'),
  ('Tour Sales Department', 'Tour package sales and customer service'),
  ('Operation Series Department', 'Operational management and logistics'),
  ('Ticketing Department', 'Ticket booking and management'),
  ('B2B Partner Department', 'Business partnership management'),
  ('Business Development Department', 'Business growth and development strategies')
ON CONFLICT (name) DO UPDATE
SET description = EXCLUDED.description
RETURNING id, name;

-- Update staff associations
DO $$
DECLARE
  v_csuite_id uuid;
  v_management_id uuid;
BEGIN
  -- Get department IDs
  SELECT id INTO v_csuite_id FROM departments WHERE name = 'C-Suite Department';
  SELECT id INTO v_management_id FROM departments WHERE name = 'Management Department';

  -- Create staff department associations
  -- Admin user gets C-Suite Department as primary department
  INSERT INTO staff_departments (staff_id, department_id, is_primary)
  SELECT id, v_csuite_id, true
  FROM staff
  WHERE email = 'admin@example.com';

  -- Staff user gets Management Department as primary department
  INSERT INTO staff_departments (staff_id, department_id, is_primary)
  SELECT id, v_management_id, true
  FROM staff
  WHERE email = 'staff@example.com';
END $$;