-- Insert staff members for Muslimtravelbug Sdn Bhd
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
  SELECT rm.id INTO v_admin_role_id FROM role_mappings rm WHERE rm.staff_level_id = v_director_id;
  SELECT rm.id INTO v_hr_role_id FROM role_mappings rm WHERE rm.staff_level_id = v_hr_level_id;
  SELECT rm.id INTO v_staff_role_id FROM role_mappings rm WHERE rm.staff_level_id = v_staff_id;

  -- Insert staff members
  -- 1. CTO
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MUHAMMAD FAKHRUZ RAZI BIN MUTUSSIN', 'fakhruz@muslimtravelbug.com', '+60123456789', v_company_id, v_admin_role_id, '2023-10-11', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_csuite_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_csuite_level_id, true);
    END IF;
  END;

  -- 2. Junior Accounting
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('HANIS MUNIRAH BINTI ZAKARIA@HASBULLAH', 'hanis@muslimtravelbug.com', '+60123456790', v_company_id, v_staff_role_id, '2024-11-04', 'probation', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_finance_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 3. Senior Account Executive
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NADIA NAJWA BINTI HUSSIN', 'nadia@muslimtravelbug.com', '+60123456791', v_company_id, v_staff_role_id, '2024-04-22', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_finance_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 4. Admin and Personal Assistant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NABILAH ALISYA BINTI NORZAIDI', 'nabilah@muslimtravelbug.com', '+60123456792', v_company_id, v_staff_role_id, '2024-11-04', 'probation', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_management_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 5. Human Resources
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NUR IMAN NABEISYA BINTI NOR AZRI', 'iman@muslimtravelbug.com', '+60123456793', v_company_id, v_hr_role_id, '2024-07-15', 'probation', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_hr_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hr_level_id, true);
    END IF;
  END;

  -- 6. Business Development Executive
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NUR SUHAILI BINTI MOHD SANI', 'suhaili@muslimtravelbug.com', '+60123456794', v_company_id, v_staff_role_id, '2021-02-27', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_b2b_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 7. Tour Manager
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('ISMAIL BIN SJAFRIAL', 'ismail@muslimtravelbug.com', '+60123456795', v_company_id, v_staff_role_id, '2017-09-18', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hod_id, true);
    END IF;
  END;

  -- 8. Series Operation Assistant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('SITI MAHIRAH BINTI HANUDDIN', 'mahirah@muslimtravelbug.com', '+60123456796', v_company_id, v_staff_role_id, '2022-07-25', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_operation_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 9. HOD Ticketing
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MUHAMMAD RIDZWAN BIN MOHD ANNUAR', 'ridzwan@muslimtravelbug.com', '+60123456797', v_company_id, v_staff_role_id, '2024-09-23', 'probation', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_ticketing_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hod_id, true);
    END IF;
  END;

  -- 10. Tour Operation Ticketing (WFH)
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NURAZEHAN BINTI MUHAMMAD', 'azehan@muslimtravelbug.com', '+60123456798', v_company_id, v_staff_role_id, '2022-09-26', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_ticketing_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- Continue with remaining staff members...
  -- [Additional staff members would follow the same pattern]

END $$;