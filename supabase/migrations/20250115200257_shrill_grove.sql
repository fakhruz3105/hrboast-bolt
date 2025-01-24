-- Drop existing tables and recreate with proper structure
DROP TABLE IF EXISTS benefit_claims CASCADE;
DROP TABLE IF EXISTS benefit_eligibility CASCADE;
DROP TABLE IF EXISTS benefits CASCADE;

-- Create the benefits table with company_id
CREATE TABLE benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  description text,
  amount numeric(10,2) NOT NULL,
  status boolean DEFAULT true,
  frequency text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_benefits_company ON benefits(company_id);
CREATE INDEX idx_benefits_status ON benefits(status);

-- Create benefit eligibility table
CREATE TABLE benefit_eligibility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_id uuid REFERENCES benefits(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(benefit_id, level_id)
);

-- Create benefit claims table
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

-- Initialize default benefits for Muslimtravelbug
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
    -- Insert default benefits
    INSERT INTO benefits (
      company_id,
      name,
      description,
      amount,
      status,
      frequency
    ) VALUES
      (v_company_id, 'Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'Annual coverage'),
      (v_company_id, 'Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'Annual coverage'),
      (v_company_id, 'Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'Annual coverage'),
      (v_company_id, 'Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'Monthly'),
      (v_company_id, 'Work From Home Setup', 'One-time allowance for home office setup', 1500.00, true, 'Once per employment'),
      (v_company_id, 'Transportation', 'Monthly transportation allowance', 200.00, true, 'Monthly'),
      (v_company_id, 'Wellness Program', 'Annual wellness program including health screenings', 800.00, true, 'Annual coverage'),
      (v_company_id, 'Education Subsidy', 'Support for continuing education', 5000.00, true, 'Annual coverage'),
      (v_company_id, 'Parental Leave', 'Paid parental leave benefit', 3000.00, true, 'Per child'),
      (v_company_id, 'Marriage Allowance', 'One-time marriage celebration allowance', 1000.00, true, 'Once per employment');

    -- Assign benefits to all staff levels
    INSERT INTO benefit_eligibility (benefit_id, level_id)
    SELECT b.id, sl.id
    FROM benefits b
    CROSS JOIN staff_levels sl
    WHERE b.company_id = v_company_id;
  END IF;
END $$;