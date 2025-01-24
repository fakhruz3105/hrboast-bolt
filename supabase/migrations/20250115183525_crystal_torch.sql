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

-- Recreate the benefits table
CREATE TABLE benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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
    (frequency = 'yearly' AND frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL) OR
    (frequency = 'monthly' AND frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL) OR
    (frequency = 'custom_months' AND frequency_months IS NOT NULL AND frequency_months > 0 AND frequency_times IS NULL AND frequency_period IS NULL) OR
    (frequency = 'custom_times_per_year' AND frequency_months IS NULL AND frequency_times IS NOT NULL AND frequency_period IS NOT NULL AND frequency_times > 0 AND frequency_period > 0) OR
    (frequency = 'once' AND frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL)
  )
);

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
CREATE POLICY "benefits_select" ON benefits FOR SELECT USING (true);
CREATE POLICY "benefits_insert" ON benefits FOR INSERT WITH CHECK (true);
CREATE POLICY "benefits_update" ON benefits FOR UPDATE USING (true);
CREATE POLICY "benefits_delete" ON benefits FOR DELETE USING (true);

CREATE POLICY "benefit_eligibility_select" ON benefit_eligibility FOR SELECT USING (true);
CREATE POLICY "benefit_eligibility_insert" ON benefit_eligibility FOR INSERT WITH CHECK (true);
CREATE POLICY "benefit_eligibility_delete" ON benefit_eligibility FOR DELETE USING (true);

CREATE POLICY "benefit_claims_select" ON benefit_claims FOR SELECT USING (true);
CREATE POLICY "benefit_claims_insert" ON benefit_claims FOR INSERT WITH CHECK (true);

-- Insert default benefits
INSERT INTO benefits (
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
WITH staff_levels_cte AS (
  SELECT id FROM staff_levels
)
INSERT INTO benefit_eligibility (benefit_id, level_id)
SELECT b.id, sl.id
FROM benefits b
CROSS JOIN staff_levels_cte sl;