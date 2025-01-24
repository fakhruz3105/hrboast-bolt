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

-- Insert new departments
INSERT INTO departments (name, description)
VALUES 
  ('C-Suite', 'Executive leadership and strategic decision making'),
  ('Management', 'Organizational management and team leadership'),
  ('Finance', 'Financial planning, accounting, and reporting'),
  ('HR', 'Human resources management and employee relations'),
  ('Tour', 'Tour planning and management'),
  ('Tour Sales', 'Tour package sales and customer service'),
  ('Operation Series', 'Operational management and logistics'),
  ('Ticketing', 'Ticket booking and management'),
  ('B2B Partner', 'Business partnership management'),
  ('Business Development', 'Business growth and development strategies')
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
  SELECT id INTO v_csuite_id FROM departments WHERE name = 'C-Suite';
  SELECT id INTO v_management_id FROM departments WHERE name = 'Management';

  -- Create staff department associations
  -- Admin user gets C-Suite as primary department
  INSERT INTO staff_departments (staff_id, department_id, is_primary)
  SELECT id, v_csuite_id, true
  FROM staff
  WHERE email = 'admin@example.com';

  -- Staff user gets Management as primary department
  INSERT INTO staff_departments (staff_id, department_id, is_primary)
  SELECT id, v_management_id, true
  FROM staff
  WHERE email = 'staff@example.com';
END $$;