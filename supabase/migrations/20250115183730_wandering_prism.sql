-- Drop existing policies
DROP POLICY IF EXISTS "benefits_select" ON benefits;
DROP POLICY IF EXISTS "benefits_insert" ON benefits;
DROP POLICY IF EXISTS "benefits_update" ON benefits;
DROP POLICY IF EXISTS "benefits_delete" ON benefits;

-- Create simplified RLS policies
CREATE POLICY "benefits_select"
  ON benefits FOR SELECT
  USING (true);  -- Allow all authenticated users to read benefits

CREATE POLICY "benefits_insert"
  ON benefits FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create benefits

CREATE POLICY "benefits_update"
  ON benefits FOR UPDATE
  USING (true);  -- Allow all authenticated users to update benefits

CREATE POLICY "benefits_delete"
  ON benefits FOR DELETE
  USING (true);  -- Allow all authenticated users to delete benefits

-- Create function to get benefits for a company
CREATE OR REPLACE FUNCTION get_company_benefits(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  frequency_months integer,
  frequency_times integer,
  frequency_period integer,
  created_at timestamptz,
  updated_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.id,
    b.name,
    b.description,
    b.amount,
    b.status,
    b.frequency::text,
    b.frequency_months,
    b.frequency_times,
    b.frequency_period,
    b.created_at,
    b.updated_at
  FROM benefits b
  WHERE b.company_id = p_company_id
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to initialize benefits for a company
CREATE OR REPLACE FUNCTION initialize_company_benefits(p_company_id uuid)
RETURNS void AS $$
BEGIN
  -- Insert default benefits
  INSERT INTO benefits (
    company_id,
    name,
    description,
    amount,
    status,
    frequency
  ) VALUES
    (p_company_id, 'Spectacles Claim', 'Annual reimbursement for prescription glasses or contact lenses', 500.00, true, 'yearly'),
    (p_company_id, 'Birthday Rewards', 'Annual birthday celebration allowance', 100.00, true, 'yearly'),
    (p_company_id, 'Medical Cards', 'Company medical card coverage for outpatient and inpatient care', 1500.00, true, 'yearly'),
    (p_company_id, 'Medical Insurance', 'Comprehensive medical insurance coverage', 2000.00, true, 'yearly'),
    (p_company_id, 'Baby Delivery', 'Maternity benefit for childbirth expenses', 3000.00, true, 'once'),
    (p_company_id, 'Children Care', 'Monthly allowance for childcare expenses', 200.00, true, 'monthly'),
    (p_company_id, 'Family Travel Scheme', 'Annual family vacation allowance', 2500.00, true, 'yearly'),
    (p_company_id, 'Office Loan', 'Interest-free loan for office equipment or furniture', 5000.00, true, 'once'),
    (p_company_id, 'Passport Renewal', 'Reimbursement for passport renewal fees', 150.00, true, 'custom_months'),
    (p_company_id, 'Marry Me Incentive', 'One-time marriage allowance for staff', 1000.00, true, 'once');

  -- Assign benefits to all staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = p_company_id;
END;
$$ LANGUAGE plpgsql;