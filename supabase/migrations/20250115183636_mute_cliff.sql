-- First drop any dependent objects
DROP TABLE IF EXISTS benefit_claims CASCADE;
DROP TABLE IF EXISTS benefit_eligibility CASCADE;
DROP TABLE IF EXISTS benefits CASCADE;
DROP TYPE IF EXISTS benefit_frequency CASCADE;

-- Recreate the enum type with 'once' option
CREATE TYPE benefit_frequency AS ENUM (
  'yearly',
  'monthly', 
  'custom_months',
  'custom_times_per_year',
  'once'
);

-- Recreate the benefits table with company_id
CREATE TABLE benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  amount numeric(10,2) NOT NULL,
  status boolean DEFAULT true,
  frequency benefit_frequency NOT NULL DEFAULT 'yearly',
  frequency_months integer,
  frequency_times integer,
  frequency_period integer,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_frequency_settings CHECK (
    CASE frequency
      WHEN 'yearly' THEN 
        frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL
      WHEN 'monthly' THEN 
        frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL
      WHEN 'custom_months' THEN 
        frequency_months IS NOT NULL AND frequency_months > 0 
        AND frequency_times IS NULL AND frequency_period IS NULL
      WHEN 'custom_times_per_year' THEN 
        frequency_months IS NULL 
        AND frequency_times IS NOT NULL AND frequency_times > 0 
        AND frequency_period IS NOT NULL AND frequency_period > 0
      WHEN 'once' THEN 
        frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL
      ELSE false
    END
  )
);

-- Create indexes
CREATE INDEX idx_benefits_company ON benefits(company_id);
CREATE INDEX idx_benefits_status ON benefits(status);
CREATE INDEX idx_benefits_frequency ON benefits(frequency);

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
  USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all benefits
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can only see their company's benefits
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "benefits_insert"
  ON benefits FOR INSERT
  WITH CHECK (
    company_id = (
      SELECT company_id FROM staff WHERE id = auth.uid()
    )
  );

CREATE POLICY "benefits_update"
  ON benefits FOR UPDATE
  USING (
    company_id = (
      SELECT company_id FROM staff WHERE id = auth.uid()
    )
  );

CREATE POLICY "benefits_delete"
  ON benefits FOR DELETE
  USING (
    company_id = (
      SELECT company_id FROM staff WHERE id = auth.uid()
    )
  );

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
    frequency,
    frequency_months,
    frequency_times,
    frequency_period
  ) VALUES
    (
      p_company_id,
      'Spectacles Claim',
      'Annual reimbursement for prescription glasses or contact lenses',
      500.00,
      true,
      'yearly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Birthday Rewards',
      'Annual birthday celebration allowance',
      100.00,
      true,
      'yearly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Medical Cards',
      'Company medical card coverage for outpatient and inpatient care',
      1500.00,
      true,
      'yearly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Medical Insurance',
      'Comprehensive medical insurance coverage',
      2000.00,
      true,
      'yearly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Baby Delivery',
      'Maternity benefit for childbirth expenses',
      3000.00,
      true,
      'once',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Children Care',
      'Monthly allowance for childcare expenses',
      200.00,
      true,
      'monthly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Family Travel Scheme',
      'Annual family vacation allowance',
      2500.00,
      true,
      'yearly',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Office Loan',
      'Interest-free loan for office equipment or furniture',
      5000.00,
      true,
      'once',
      NULL,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Passport Renewal',
      'Reimbursement for passport renewal fees',
      150.00,
      true,
      'custom_months',
      60,
      NULL,
      NULL
    ),
    (
      p_company_id,
      'Marry Me Incentive',
      'One-time marriage allowance for staff',
      1000.00,
      true,
      'once',
      NULL,
      NULL,
      NULL
    );

  -- Assign benefits to all staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = p_company_id;
END;
$$ LANGUAGE plpgsql;