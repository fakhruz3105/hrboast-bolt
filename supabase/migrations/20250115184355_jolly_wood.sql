-- First drop all dependent objects
DROP TABLE IF EXISTS benefit_claims CASCADE;
DROP TABLE IF EXISTS benefit_eligibility CASCADE;
DROP TABLE IF EXISTS benefits CASCADE;

-- Recreate the benefits table with simplified structure
CREATE TABLE benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  amount numeric(10,2) NOT NULL,
  status boolean DEFAULT true,
  frequency text NOT NULL, -- Simple text field for frequency description
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_benefits_company ON benefits(company_id);
CREATE INDEX idx_benefits_status ON benefits(status);

-- Recreate benefit eligibility table
CREATE TABLE benefit_eligibility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_id uuid REFERENCES benefits(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(benefit_id, level_id)
);

-- Recreate benefit claims table
CREATE TABLE benefit_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_id uuid REFERENCES benefits(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  amount numeric(10,2) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  claim_date date NOT NULL DEFAULT CURRENT_DATE,
  receipt_url text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_eligibility ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_claims ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "benefits_select"
  ON benefits FOR SELECT
  USING (true);

CREATE POLICY "benefits_insert"
  ON benefits FOR INSERT
  WITH CHECK (true);

CREATE POLICY "benefits_update"
  ON benefits FOR UPDATE
  USING (true);

CREATE POLICY "benefits_delete"
  ON benefits FOR DELETE
  USING (true);

CREATE POLICY "benefit_eligibility_select"
  ON benefit_eligibility FOR SELECT
  USING (true);

CREATE POLICY "benefit_eligibility_insert"
  ON benefit_eligibility FOR INSERT
  WITH CHECK (true);

CREATE POLICY "benefit_eligibility_delete"
  ON benefit_eligibility FOR DELETE
  USING (true);

CREATE POLICY "benefit_claims_select"
  ON benefit_claims FOR SELECT
  USING (true);

CREATE POLICY "benefit_claims_insert"
  ON benefit_claims FOR INSERT
  WITH CHECK (true);

-- Create function to get benefits for a company
CREATE OR REPLACE FUNCTION get_company_benefits(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
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
    b.frequency,
    b.created_at,
    b.updated_at
  FROM benefits b
  WHERE b.company_id = p_company_id
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to initialize default benefits for a company
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
    (p_company_id, 'Spectacles Claim', 'Annual reimbursement for prescription glasses or contact lenses', 500.00, true, 'Once per year'),
    (p_company_id, 'Birthday Rewards', 'Annual birthday celebration allowance', 100.00, true, 'Once per year'),
    (p_company_id, 'Medical Cards', 'Company medical card coverage for outpatient and inpatient care', 1500.00, true, 'Annual coverage'),
    (p_company_id, 'Medical Insurance', 'Comprehensive medical insurance coverage', 2000.00, true, 'Annual coverage'),
    (p_company_id, 'Baby Delivery', 'Maternity benefit for childbirth expenses', 3000.00, true, 'Once per child'),
    (p_company_id, 'Children Care', 'Monthly allowance for childcare expenses', 200.00, true, 'Monthly'),
    (p_company_id, 'Family Travel Scheme', 'Annual family vacation allowance', 2500.00, true, 'Once per year'),
    (p_company_id, 'Office Loan', 'Interest-free loan for office equipment or furniture', 5000.00, true, 'Once per employment'),
    (p_company_id, 'Passport Renewal', 'Reimbursement for passport renewal fees', 150.00, true, 'Every 5 years'),
    (p_company_id, 'Marry Me Incentive', 'One-time marriage allowance for staff', 1000.00, true, 'Once per employment');

  -- Assign benefits to all staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = p_company_id;
END;
$$ LANGUAGE plpgsql;