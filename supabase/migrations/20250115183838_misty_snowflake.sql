-- First drop all dependent objects
DROP TABLE IF EXISTS benefit_claims CASCADE;
DROP TABLE IF EXISTS benefit_eligibility CASCADE;
DROP TABLE IF EXISTS benefits CASCADE;
DROP TYPE IF EXISTS benefit_frequency CASCADE;

-- Recreate the enum type with all frequencies
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