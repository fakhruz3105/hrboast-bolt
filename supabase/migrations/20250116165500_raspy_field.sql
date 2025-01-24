-- Create Nuh Travel company if it doesn't exist
DO $$
DECLARE
  v_nuh_id uuid;
  v_csuite_dept_id uuid;
  v_management_dept_id uuid;
  v_finance_dept_id uuid;
  v_hr_dept_id uuid;
  v_operations_dept_id uuid;
  v_sales_dept_id uuid;
  
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
  -- Create Nuh Travel if it doesn't exist
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    subscription_status,
    trial_ends_at,
    is_active
  ) VALUES (
    'Nuh Travel',
    'admin@nuhtravel.com',
    '+60123456789',
    'Kuala Lumpur, Malaysia',
    'trial',
    now() + interval '14 days',
    true
  )
  ON CONFLICT (email) DO UPDATE
  SET name = EXCLUDED.name
  RETURNING id INTO v_nuh_id;

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

  -- Create departments for Nuh Travel
  INSERT INTO departments (name, description)
  VALUES 
    ('C-Suite Department', 'Executive leadership team'),
    ('Management Department', 'Management and administration'),
    ('Finance Department', 'Financial management and accounting'),
    ('HR Department', 'Human resources management'),
    ('Operations Department', 'Travel operations and logistics'),
    ('Sales Department', 'Sales and customer service')
  ON CONFLICT (name) DO NOTHING;

  -- Get department IDs
  SELECT id INTO v_csuite_dept_id FROM departments WHERE name = 'C-Suite Department';
  SELECT id INTO v_management_dept_id FROM departments WHERE name = 'Management Department';
  SELECT id INTO v_finance_dept_id FROM departments WHERE name = 'Finance Department';
  SELECT id INTO v_hr_dept_id FROM departments WHERE name = 'HR Department';
  SELECT id INTO v_operations_dept_id FROM departments WHERE name = 'Operations Department';
  SELECT id INTO v_sales_dept_id FROM departments WHERE name = 'Sales Department';

  -- Create admin user for Nuh Travel
  INSERT INTO staff (
    name,
    email,
    phone_number,
    company_id,
    role_id,
    join_date,
    status,
    is_active
  ) VALUES (
    'Nuh Travel Admin',
    'nuh@gmail.com',
    '+60123456789',
    v_nuh_id,
    v_admin_role_id,
    CURRENT_DATE,
    'permanent',
    true
  )
  ON CONFLICT (email) DO UPDATE
  SET 
    role_id = EXCLUDED.role_id,
    company_id = EXCLUDED.company_id
  RETURNING id INTO v_new_staff_id;

  -- Create department and level associations for admin
  INSERT INTO staff_departments (staff_id, department_id, is_primary)
  VALUES (v_new_staff_id, v_csuite_dept_id, true)
  ON CONFLICT (staff_id, department_id) DO NOTHING;

  INSERT INTO staff_levels_junction (staff_id, level_id, is_primary)
  VALUES (v_new_staff_id, v_director_id, true)
  ON CONFLICT (staff_id, level_id) DO NOTHING;

  -- Initialize benefits for Nuh Travel
  INSERT INTO benefits (
    company_id,
    name,
    description,
    amount,
    status,
    frequency
  ) VALUES
    (v_nuh_id, 'Travel Allowance', 'Monthly travel allowance for staff', 300.00, true, 'Monthly'),
    (v_nuh_id, 'Hotel Discounts', 'Staff discounts on partner hotels', 2000.00, true, 'Annual coverage'),
    (v_nuh_id, 'Flight Benefits', 'Annual flight ticket allowance', 3000.00, true, 'Annual coverage'),
    (v_nuh_id, 'Medical Coverage', 'Basic medical insurance coverage', 2500.00, true, 'Annual coverage'),
    (v_nuh_id, 'Training Fund', 'Professional development fund', 1500.00, true, 'Annual coverage')
  ON CONFLICT DO NOTHING;

  -- Assign benefits to staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = v_nuh_id
  ON CONFLICT DO NOTHING;

END $$;