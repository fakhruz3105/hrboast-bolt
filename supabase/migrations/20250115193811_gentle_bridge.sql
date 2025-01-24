-- Continue inserting remaining staff members
DO $$
DECLARE
  v_company_id uuid;
  v_tour_dept_id uuid;
  v_tour_sales_dept_id uuid;
  v_operation_dept_id uuid;
  v_ticketing_dept_id uuid;
  v_b2b_dept_id uuid;
  
  v_hod_id uuid;
  v_staff_id uuid;
  
  v_staff_role_id uuid;
  
  v_new_staff_id uuid;
BEGIN
  -- Get company ID
  SELECT id INTO v_company_id FROM companies WHERE name = 'Muslimtravelbug Sdn Bhd';

  -- Get department IDs
  SELECT id INTO v_tour_dept_id FROM departments WHERE name = 'Tour Department';
  SELECT id INTO v_tour_sales_dept_id FROM departments WHERE name = 'Tour Sales Department';
  SELECT id INTO v_operation_dept_id FROM departments WHERE name = 'Operation Series Department';
  SELECT id INTO v_ticketing_dept_id FROM departments WHERE name = 'Ticketing Department';
  SELECT id INTO v_b2b_dept_id FROM departments WHERE name = 'B2B Partner Department';

  -- Get level IDs
  SELECT id INTO v_hod_id FROM staff_levels WHERE name = 'HOD/Manager';
  SELECT id INTO v_staff_id FROM staff_levels WHERE name = 'Staff';

  -- Get role ID
  SELECT rm.id INTO v_staff_role_id FROM role_mappings rm WHERE rm.staff_level_id = v_staff_id;

  -- 11. Tour Operation Ticketing (WFH)
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('LIYANA SYAZANA BINTI KAMARUDIN', 'liyana@muslimtravelbug.com', '+60123456799', v_company_id, v_staff_role_id, '2024-01-30', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_ticketing_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 12. HOD Tour Consultant cum Marketing
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('BASHIER BIN OMAR', 'bashier@muslimtravelbug.com', '+60123456800', v_company_id, v_staff_role_id, '2022-10-25', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hod_id, true);
    END IF;
  END;

  -- 13. Tour Consultant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NUR SHAHIRA BINTI OTHMAN', 'shahira@muslimtravelbug.com', '+60123456801', v_company_id, v_staff_role_id, '2022-08-19', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 14. Tour Consultant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('SYAZA RAKIN BIN DARSONO', 'syaza@muslimtravelbug.com', '+60123456802', v_company_id, v_staff_role_id, '2023-02-27', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 15. Tour Consultant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MUHAMMAD AMMAR BIN MOHD AZIS', 'ammar@muslimtravelbug.com', '+60123456803', v_company_id, v_staff_role_id, '2022-12-27', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 16. Cruise Operation cum Tour Consultant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NUR FAZIELA BINTI ISDAM', 'faziela@muslimtravelbug.com', '+60123456804', v_company_id, v_staff_role_id, '2021-07-12', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 17. Tour Consultant
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NURHANI IZNI BINTI JA''APAR', 'hani@muslimtravelbug.com', '+60123456805', v_company_id, v_staff_role_id, '2023-07-03', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_sales_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 18. Business Corporate cum Sales Manager
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MAZLON BINTI NAIM', 'mazlon@muslimtravelbug.com', '+60123456806', v_company_id, v_staff_role_id, '2022-06-24', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_b2b_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hod_id, true);
    END IF;
  END;

  -- 19. Sales Consultant B2B
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('MURSYID BIN AZMI', 'mursyid@muslimtravelbug.com', '+60123456807', v_company_id, v_staff_role_id, '2022-06-24', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_b2b_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 20. HOD Tour Department
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NURUL HIDAYAH BINTI ABD HAMID', 'hidayah@muslimtravelbug.com', '+60123456808', v_company_id, v_staff_role_id, '2024-11-18', 'probation', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_hod_id, true);
    END IF;
  END;

  -- 21. Tour Operation Exec
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('ALIF ASYRAAF BIN MOHD FADHIL SAMUEL', 'alif@muslimtravelbug.com', '+60123456809', v_company_id, v_staff_role_id, '2023-08-15', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 22. Tour Assistance
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('DZULAIFATUN NUHA BINTI ZOLKIFLI', 'nuha@muslimtravelbug.com', '+60123456810', v_company_id, v_staff_role_id, '2023-03-24', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

  -- 23. Senior Tour Op (FIT/MICE)
  BEGIN
    INSERT INTO staff (name, email, phone_number, company_id, role_id, join_date, status, is_active)
    VALUES ('NUR ZUHRIYANA BTE JAMALUDIN', 'zuhriyana@muslimtravelbug.com', '+60123456811', v_company_id, v_staff_role_id, '2024-04-16', 'permanent', true)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO v_new_staff_id;
    
    IF v_new_staff_id IS NOT NULL THEN
      INSERT INTO staff_departments (staff_id, department_id, is_primary) VALUES (v_new_staff_id, v_tour_dept_id, true);
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary) VALUES (v_new_staff_id, v_staff_id, true);
    END IF;
  END;

END $$;