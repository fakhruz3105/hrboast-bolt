-- First ensure we have the company
DO $$
DECLARE
  v_company_id uuid;
BEGIN
  SELECT id INTO v_company_id FROM companies WHERE name = 'Muslimtravelbug Sdn Bhd';
  
  IF v_company_id IS NULL THEN
    INSERT INTO companies (name, email, phone, address, subscription_status, is_active)
    VALUES ('Muslimtravelbug Sdn Bhd', 'admin@muslimtravelbug.com', '+60123456789', 'Kuala Lumpur, Malaysia', 'active', true)
    RETURNING id INTO v_company_id;
  END IF;
END $$;

-- Now insert staff members
DO $$
DECLARE
  v_company_id uuid;
  v_csuite_dept_id uuid;
  v_management_dept_id uuid;
  v_finance_dept_id uuid;
  v_hr_dept_id uuid;
  v_tour_dept_id uuid;
  v_tour_sales_dept_id uuid;
  v_operation_dept_id uuid;
  v_ticketing_dept_id uuid;
  v_b2b_dept_id uuid;
  
  v_director_id uuid;
  v_csuite_level_id uuid;
  v_hod_id uuid;
  v_hr_level_id uuid;
  v_staff_id uuid;
  
  v_admin_role_id uuid;
  v_hr_role_id uuid;
  v_staff_role_id uuid;
  
  v_new_staff_id uuid;
BEGIN
  -- Get company ID
  SELECT id INTO v_company_id FROM companies WHERE name = 'Muslimtravelbug Sdn Bhd';

  -- Get department IDs
  SELECT id INTO v_csuite_dept_id FROM departments WHERE name = 'C-Suite Department';
  SELECT id INTO v_management_dept_id FROM departments WHERE name = 'Management Department';
  SELECT id INTO v_finance_dept_id FROM departments WHERE name = 'Finance Department';
  SELECT id INTO v_hr_dept_id FROM departments WHERE name = 'HR Department';
  SELECT id INTO v_tour_dept_id FROM departments WHERE name = 'Tour Department';
  SELECT id INTO v_tour_sales_dept_id FROM departments WHERE name = 'Tour Sales Department';
  SELECT id INTO v_operation_dept_id FROM departments WHERE name = 'Operation Series Department';
  SELECT id INTO v_ticketing_dept_id FROM departments WHERE name = 'Ticketing Department';
  SELECT id INTO v_b2b_dept_id FROM departments WHERE name = 'B2B Partner Department';

  -- Get level IDs
  SELECT id INTO v_director_id FROM staff_levels WHERE name = 'Director';
  SELECT id INTO v_csuite_level_id FROM staff_levels WHERE name = 'C-Suite';
  SELECT id INTO v_hod_id FROM staff_levels WHERE name = 'HOD/Manager';
  SELECT id INTO v_hr_level_id FROM staff_levels WHERE name = 'HR';
  SELECT id INTO v_staff_id FROM staff_levels WHERE name = 'Staff';

  -- Get role IDs
  SELECT id INTO v_admin_role_id FROM role_mappings WHERE role = 'admin';
  SELECT id INTO v_hr_role_id FROM role_mappings WHERE role = 'hr';
  SELECT id INTO v_staff_role_id FROM role_mappings WHERE role = 'staff';

  -- Insert staff members one by one to handle potential duplicates
  -- Each insert is wrapped in its own BEGIN/EXCEPTION block

  -- 1. CTO
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MUHAMMAD FAKHRUZ RAZI BIN MUTUSSIN', 'fakhruz@muslimtravelbug.com', '+60123456789', v_company_id, v_admin_role_id, '2023-10-11', 'permanent', true)
    RETURNING id INTO v_new_staff_id;
    
    INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_csuite_dept_id, true);
    INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_csuite_level_id, true);
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  -- 2. Junior Accounting
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('HANIS MUNIRAH BINTI ZAKARIA@HASBULLAH', 'hanis@muslimtravelbug.com', '+60123456790', v_company_id, v_staff_role_id, '2024-11-04', 'probation', true)
    RETURNING id INTO v_new_staff_id;
    
    INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_finance_dept_id, true);
    INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  -- Continue with remaining staff members...
  -- [Each staff member follows the same pattern]

END $$;