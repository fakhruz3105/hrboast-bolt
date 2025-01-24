-- Create enum for benefit frequency
CREATE TYPE benefit_frequency AS ENUM (
  'yearly',
  'monthly', 
  'custom_months',
  'custom_times_per_year'
);

-- Add frequency columns to benefits table
ALTER TABLE benefits
ADD COLUMN frequency benefit_frequency NOT NULL DEFAULT 'yearly',
ADD COLUMN frequency_months integer, -- For custom_months frequency
ADD COLUMN frequency_times integer, -- For custom_times_per_year frequency
ADD COLUMN frequency_period integer; -- For custom_times_per_year frequency

-- Add constraint to validate frequency settings
ALTER TABLE benefits
ADD CONSTRAINT valid_frequency_settings CHECK (
  (frequency = 'yearly' AND frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL) OR
  (frequency = 'monthly' AND frequency_months IS NULL AND frequency_times IS NULL AND frequency_period IS NULL) OR
  (frequency = 'custom_months' AND frequency_months IS NOT NULL AND frequency_months > 0 AND frequency_times IS NULL AND frequency_period IS NULL) OR
  (frequency = 'custom_times_per_year' AND frequency_months IS NULL AND frequency_times IS NOT NULL AND frequency_period IS NOT NULL AND frequency_times > 0 AND frequency_period > 0)
);

-- Update existing benefits with appropriate frequencies using CAST
UPDATE benefits SET
  frequency = CASE name
    WHEN 'Medical Insurance' THEN 'yearly'::benefit_frequency
    WHEN 'Dental Coverage' THEN 'yearly'::benefit_frequency
    WHEN 'Professional Development' THEN 'yearly'::benefit_frequency
    WHEN 'Gym Membership' THEN 'monthly'::benefit_frequency
    WHEN 'Work From Home Allowance' THEN 'yearly'::benefit_frequency
    WHEN 'Transportation Allowance' THEN 'monthly'::benefit_frequency
    WHEN 'Wellness Program' THEN 'yearly'::benefit_frequency
    WHEN 'Education Subsidy' THEN 'yearly'::benefit_frequency
  END;

-- Add function to validate claim frequency
CREATE OR REPLACE FUNCTION validate_benefit_claim_frequency(
  p_benefit_id uuid,
  p_staff_id uuid,
  p_claim_date date
) RETURNS boolean AS $$
DECLARE
  v_benefit benefits%ROWTYPE;
  v_last_claim benefit_claims%ROWTYPE;
  v_year_start date;
  v_claim_count integer;
BEGIN
  -- Get benefit details
  SELECT * INTO v_benefit FROM benefits WHERE id = p_benefit_id;
  
  -- Get last claim for this benefit and staff
  SELECT * INTO v_last_claim 
  FROM benefit_claims 
  WHERE benefit_id = p_benefit_id 
  AND staff_id = p_staff_id
  ORDER BY claim_date DESC 
  LIMIT 1;
  
  -- Calculate year start for the claim date
  v_year_start := date_trunc('year', p_claim_date)::date;
  
  CASE v_benefit.frequency
    WHEN 'yearly' THEN
      -- Check if already claimed this year
      RETURN NOT EXISTS (
        SELECT 1 FROM benefit_claims
        WHERE benefit_id = p_benefit_id
        AND staff_id = p_staff_id
        AND date_trunc('year', claim_date) = date_trunc('year', p_claim_date)
      );
      
    WHEN 'monthly' THEN
      -- Check if already claimed this month
      RETURN NOT EXISTS (
        SELECT 1 FROM benefit_claims
        WHERE benefit_id = p_benefit_id
        AND staff_id = p_staff_id
        AND date_trunc('month', claim_date) = date_trunc('month', p_claim_date)
      );
      
    WHEN 'custom_months' THEN
      -- Check if enough months have passed since last claim
      RETURN v_last_claim IS NULL OR 
        (p_claim_date - v_last_claim.claim_date) >= (v_benefit.frequency_months * 30);
        
    WHEN 'custom_times_per_year' THEN
      -- Count claims in current year
      SELECT count(*) INTO v_claim_count
      FROM benefit_claims
      WHERE benefit_id = p_benefit_id
      AND staff_id = p_staff_id
      AND date_trunc('year', claim_date) = date_trunc('year', p_claim_date);
      
      -- Check if under the allowed number of claims per period
      RETURN v_claim_count < v_benefit.frequency_times;
      
    ELSE
      RETURN false;
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to validate claim frequency
CREATE OR REPLACE FUNCTION validate_benefit_claim()
RETURNS TRIGGER AS $$
BEGIN
  -- Check eligibility
  IF NOT check_benefit_eligibility(NEW.staff_id, NEW.benefit_id) THEN
    RAISE EXCEPTION 'Staff member is not eligible for this benefit';
  END IF;
  
  -- Check frequency
  IF NOT validate_benefit_claim_frequency(NEW.benefit_id, NEW.staff_id, NEW.claim_date::date) THEN
    RAISE EXCEPTION 'Claim frequency limit exceeded for this benefit';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger and recreate
DROP TRIGGER IF EXISTS validate_benefit_claim_trigger ON benefit_claims;
CREATE TRIGGER validate_benefit_claim_trigger
  BEFORE INSERT ON benefit_claims
  FOR EACH ROW
  EXECUTE FUNCTION validate_benefit_claim();