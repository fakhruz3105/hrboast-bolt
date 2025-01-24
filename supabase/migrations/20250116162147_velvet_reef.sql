-- First ensure we have both companies
DO $$
DECLARE
  v_mtb_id uuid;
  v_nuh_id uuid;
BEGIN
  -- Get Muslimtravelbug ID
  SELECT id INTO v_mtb_id 
  FROM companies 
  WHERE name = 'Muslimtravelbug Sdn Bhd';

  -- Get or create Nuh Travel
  SELECT id INTO v_nuh_id 
  FROM companies 
  WHERE name = 'Nuh Travel';

  IF v_nuh_id IS NULL THEN
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
    ) RETURNING id INTO v_nuh_id;
  END IF;

  -- Initialize default benefits for Nuh Travel
  IF v_nuh_id IS NOT NULL THEN
    -- Insert default benefits
    INSERT INTO benefits (
      company_id,
      name,
      description,
      amount,
      status,
      frequency
    ) VALUES
      (v_nuh_id, 'Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'Annual coverage'),
      (v_nuh_id, 'Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'Annual coverage'),
      (v_nuh_id, 'Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'Annual coverage'),
      (v_nuh_id, 'Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'Monthly'),
      (v_nuh_id, 'Work From Home Setup', 'One-time allowance for home office setup', 1500.00, true, 'Once per employment'),
      (v_nuh_id, 'Transportation', 'Monthly transportation allowance', 200.00, true, 'Monthly'),
      (v_nuh_id, 'Wellness Program', 'Annual wellness program including health screenings', 800.00, true, 'Annual coverage'),
      (v_nuh_id, 'Education Subsidy', 'Support for continuing education', 5000.00, true, 'Annual coverage'),
      (v_nuh_id, 'Parental Leave', 'Paid parental leave benefit', 3000.00, true, 'Per child'),
      (v_nuh_id, 'Marriage Allowance', 'One-time marriage celebration allowance', 1000.00, true, 'Once per employment');

    -- Assign benefits to all staff levels
    INSERT INTO benefit_eligibility (benefit_id, level_id)
    SELECT b.id, sl.id
    FROM benefits b
    CROSS JOIN staff_levels sl
    WHERE b.company_id = v_nuh_id;
  END IF;
END $$;

-- Create function to get company details
CREATE OR REPLACE FUNCTION get_company_details(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  phone text,
  address text,
  subscription_status text,
  trial_ends_at timestamptz,
  is_active boolean,
  staff_count bigint,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.name,
    c.email,
    c.phone,
    c.address,
    c.subscription_status,
    c.trial_ends_at,
    c.is_active,
    COUNT(s.id) as staff_count,
    c.created_at
  FROM companies c
  LEFT JOIN staff s ON s.company_id = c.id
  WHERE c.id = p_company_id
  GROUP BY c.id;
END;
$$ LANGUAGE plpgsql;