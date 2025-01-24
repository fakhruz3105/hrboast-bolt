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
CREATE POLICY "benefit_eligibility_select" ON benefit_eligibility FOR SELECT USING (true);
CREATE POLICY "benefit_claims_select" ON benefit_claims FOR SELECT USING (true);