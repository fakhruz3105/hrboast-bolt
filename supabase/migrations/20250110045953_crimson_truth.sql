-- First delete all dependent records in the correct order
DELETE FROM evaluation_responses;
DELETE FROM evaluation_form_departments;
DELETE FROM evaluation_form_levels;
DELETE FROM evaluation_forms;
DELETE FROM benefit_claims;
DELETE FROM benefit_eligibility;
DELETE FROM kpi_feedback;
DELETE FROM kpis;
DELETE FROM memos;
DELETE FROM staff_departments;
DELETE FROM staff_levels_junction;
DELETE FROM staff WHERE email != 'admin@example.com';

-- Insert staff members with proper error handling
DO $$
DECLARE
  v_staff_id uuid;
  v_department_id uuid;
  v_level_id uuid;
  v_role_id uuid;
BEGIN
  -- Get department IDs
  SELECT id INTO v_department_id FROM departments WHERE name = 'Engineering Department';
  
  -- Get level ID for Staff level
  SELECT id INTO v_level_id FROM staff_levels WHERE name = 'Staff';
  
  -- Get role ID for staff role
  SELECT id INTO v_role_id FROM role_mappings WHERE role = 'staff';

  -- Insert demo staff user
  INSERT INTO staff (
    name,
    email,
    phone_number,
    role_id,
    join_date,
    status
  ) VALUES (
    'Demo Staff',
    'staff@example.com',
    '+60123456789',
    v_role_id,
    CURRENT_DATE,
    'permanent'
  ) RETURNING id INTO v_staff_id;

  -- Create department association
  INSERT INTO staff_departments (
    staff_id,
    department_id,
    is_primary
  ) VALUES (
    v_staff_id,
    v_department_id,
    true
  );

  -- Create level association  
  INSERT INTO staff_levels_junction (
    staff_id,
    level_id,
    is_primary
  ) VALUES (
    v_staff_id,
    v_level_id,
    true
  );

EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error inserting staff: %', SQLERRM;
END $$;