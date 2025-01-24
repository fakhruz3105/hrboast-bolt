-- First, delete all dependent records
DELETE FROM warning_letters;
DELETE FROM hr_letters;
DELETE FROM evaluation_responses;
DELETE FROM benefit_claims;
DELETE FROM staff_departments;
DELETE FROM staff_levels_junction;
DELETE FROM staff WHERE email != 'admin@example.com';

-- Insert 20 staff members with varied roles
DO $$
DECLARE
  -- Department variables
  v_csuite_id uuid;
  v_management_id uuid;
  v_finance_id uuid;
  v_hr_id uuid;
  v_tour_id uuid;
  v_tour_sales_id uuid;
  v_operation_id uuid;
  v_ticketing_id uuid;
  v_b2b_id uuid;
  v_business_dev_id uuid;
  
  -- Level variables
  v_director_id uuid;
  v_csuite_level_id uuid;
  v_hod_id uuid;
  v_hr_level_id uuid;
  v_staff_id uuid;
  v_practical_id uuid;
  
  -- Role mapping variables
  v_admin_role_id uuid;
  v_hr_role_id uuid;
  v_staff_role_id uuid;
  
  -- New staff ID
  v_new_staff_id uuid;
BEGIN
  -- Get department IDs
  SELECT id INTO v_csuite_id FROM departments WHERE name = 'C-Suite Department';
  SELECT id INTO v_management_id FROM departments WHERE name = 'Management Department';
  SELECT id INTO v_finance_id FROM departments WHERE name = 'Finance Department';
  SELECT id INTO v_hr_id FROM departments WHERE name = 'HR Department';
  SELECT id INTO v_tour_id FROM departments WHERE name = 'Tour Department';
  SELECT id INTO v_tour_sales_id FROM departments WHERE name = 'Tour Sales Department';
  SELECT id INTO v_operation_id FROM departments WHERE name = 'Operation Series Department';
  SELECT id INTO v_ticketing_id FROM departments WHERE name = 'Ticketing Department';
  SELECT id INTO v_b2b_id FROM departments WHERE name = 'B2B Partner Department';
  SELECT id INTO v_business_dev_id FROM departments WHERE name = 'Business Development Department';

  -- Get level IDs
  SELECT id INTO v_director_id FROM staff_levels WHERE name = 'Director';
  SELECT id INTO v_csuite_level_id FROM staff_levels WHERE name = 'C-Suite';
  SELECT id INTO v_hod_id FROM staff_levels WHERE name = 'HOD/Manager';
  SELECT id INTO v_hr_level_id FROM staff_levels WHERE name = 'HR';
  SELECT id INTO v_staff_id FROM staff_levels WHERE name = 'Staff';
  SELECT id INTO v_practical_id FROM staff_levels WHERE name = 'Practical';

  -- Get role IDs
  SELECT id INTO v_admin_role_id FROM role_mappings WHERE role = 'admin';
  SELECT id INTO v_hr_role_id FROM role_mappings WHERE role = 'hr';
  SELECT id INTO v_staff_role_id FROM role_mappings WHERE role = 'staff';

  -- 1. CEO
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('John Chen', 'john.chen@company.com', '+60123456789', v_admin_role_id, '2020-01-01', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_csuite_id, true),
    (v_new_staff_id, v_management_id, false);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_director_id, true);

  -- 2. CFO
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Sarah Wong', 'sarah.wong@company.com', '+60123456790', v_admin_role_id, '2020-02-01', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_finance_id, true),
    (v_new_staff_id, v_csuite_id, false);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_csuite_level_id, true);

  -- 3. HR Director
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Aisha Abdullah', 'aisha.abdullah@company.com', '+60123456791', v_hr_role_id, '2020-03-01', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_hr_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hod_id, true);

  -- 4. Tour Department Manager
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Raj Kumar', 'raj.kumar@company.com', '+60123456792', v_staff_role_id, '2020-04-01', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_tour_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hod_id, true);

  -- 5. Senior HR Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Lisa Tan', 'lisa.tan@company.com', '+60123456793', v_hr_role_id, '2021-01-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_hr_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hr_level_id, true);

  -- 6. Finance Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('David Lee', 'david.lee@company.com', '+60123456794', v_staff_role_id, '2021-02-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_finance_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 7. Tour Sales Manager
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Mary Lim', 'mary.lim@company.com', '+60123456795', v_staff_role_id, '2021-03-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_tour_sales_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hod_id, true);

  -- 8. Operations Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Ahmad Ismail', 'ahmad.ismail@company.com', '+60123456796', v_staff_role_id, '2021-04-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_operation_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 9. Ticketing Supervisor
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Jenny Chong', 'jenny.chong@company.com', '+60123456797', v_staff_role_id, '2021-05-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_ticketing_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hod_id, true);

  -- 10. B2B Partnership Manager
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Michael Tan', 'michael.tan@company.com', '+60123456798', v_staff_role_id, '2021-06-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_b2b_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hod_id, true);

  -- 11. Business Development Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Siti Aminah', 'siti.aminah@company.com', '+60123456799', v_staff_role_id, '2022-01-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_business_dev_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 12. Tour Guide
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Peter Zhang', 'peter.zhang@company.com', '+60123456800', v_staff_role_id, '2022-02-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_tour_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 13. Sales Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Grace Lee', 'grace.lee@company.com', '+60123456801', v_staff_role_id, '2022-03-15', 'probation')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_tour_sales_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 14. HR Assistant
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Nurul Hassan', 'nurul.hassan@company.com', '+60123456802', v_hr_role_id, '2022-04-15', 'probation')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_hr_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_hr_level_id, true);

  -- 15. Finance Intern
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Alex Wong', 'alex.wong@company.com', '+60123456803', v_staff_role_id, '2023-01-15', 'probation')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_finance_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_practical_id, true);

  -- 16. Operations Intern
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Samantha Loh', 'samantha.loh@company.com', '+60123456804', v_staff_role_id, '2023-02-15', 'probation')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_operation_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_practical_id, true);

  -- 17. Ticketing Staff
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Kamal Ibrahim', 'kamal.ibrahim@company.com', '+60123456805', v_staff_role_id, '2023-03-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_ticketing_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 18. B2B Partnership Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Rachel Tan', 'rachel.tan@company.com', '+60123456806', v_staff_role_id, '2023-04-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_b2b_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

  -- 19. Business Development Intern
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Jason Lim', 'jason.lim@company.com', '+60123456807', v_staff_role_id, '2023-05-15', 'probation')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_business_dev_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_practical_id, true);

  -- 20. Tour Sales Executive
  INSERT INTO staff (name, email, phone_number, role_id, join_date, status)
  VALUES ('Linda Cheung', 'linda.cheung@company.com', '+60123456808', v_staff_role_id, '2023-06-15', 'permanent')
  RETURNING id INTO v_new_staff_id;
  
  INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES
    (v_new_staff_id, v_tour_sales_id, true);
  
  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES
    (v_new_staff_id, v_staff_id, true);

END $$;