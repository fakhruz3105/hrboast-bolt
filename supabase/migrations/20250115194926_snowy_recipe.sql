-- Insert default benefits for Muslimtravelbug Sdn Bhd
DO $$
DECLARE
  v_company_id uuid;
BEGIN
  -- Get Muslimtravelbug company ID
  SELECT id INTO v_company_id
  FROM companies 
  WHERE name = 'Muslimtravelbug Sdn Bhd'
  LIMIT 1;

  IF v_company_id IS NOT NULL THEN
    -- First delete any existing benefits
    DELETE FROM benefits WHERE company_id = v_company_id;

    -- Insert default benefits
    INSERT INTO benefits (
      company_id,
      name,
      description,
      amount,
      status,
      frequency
    ) VALUES
      (v_company_id, 'Spectacles Claim', 'Annual reimbursement for prescription glasses or contact lenses', 500.00, true, ''),
      (v_company_id, 'Birthday Rewards', 'Annual birthday celebration allowance', 100.00, true, ''),
      (v_company_id, 'Medical Cards', 'Company medical card coverage for outpatient and inpatient care', 1500.00, true, ''),
      (v_company_id, 'Medical Insurance', 'Comprehensive medical insurance coverage', 2000.00, true, ''),
      (v_company_id, 'Baby Delivery', 'Maternity benefit for childbirth expenses', 3000.00, true, ''),
      (v_company_id, 'Children Care', 'Monthly allowance for childcare expenses', 200.00, true, ''),
      (v_company_id, 'Family Travel Scheme', 'Annual family vacation allowance', 2500.00, true, ''),
      (v_company_id, 'Office Loan', 'Interest-free loan for office equipment or furniture', 5000.00, true, ''),
      (v_company_id, 'Passport Renewal', 'Reimbursement for passport renewal fees', 150.00, true, ''),
      (v_company_id, 'Marry Me Incentive', 'One-time marriage allowance for staff', 1000.00, true, '');

    -- Assign benefits to all staff levels
    INSERT INTO benefit_eligibility (benefit_id, level_id)
    SELECT b.id, sl.id
    FROM benefits b
    CROSS JOIN staff_levels sl
    WHERE b.company_id = v_company_id;
  END IF;
END $$;