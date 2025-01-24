-- Drop existing function
DROP FUNCTION IF EXISTS get_staff_eligible_benefits;

-- Create improved function that uses the junction table
CREATE OR REPLACE FUNCTION get_staff_eligible_benefits(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  frequency_period integer,
  created_at timestamptz,
  updated_at timestamptz,
  is_eligible boolean
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
    b.frequency_period,
    b.created_at,
    b.updated_at,
    EXISTS (
      SELECT 1 
      FROM benefit_eligibility be
      JOIN staff_levels_junction slj ON be.level_id = slj.level_id
      WHERE be.benefit_id = b.id 
      AND slj.staff_id = staff_uid
      AND slj.is_primary = true
    ) as is_eligible
  FROM benefits b
  WHERE b.status = true
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Update the benefit claim validation function
CREATE OR REPLACE FUNCTION validate_benefit_claim()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if staff member is eligible for this benefit
  IF NOT EXISTS (
    SELECT 1
    FROM benefit_eligibility be
    JOIN staff_levels_junction slj ON be.level_id = slj.level_id
    WHERE be.benefit_id = NEW.benefit_id
    AND slj.staff_id = NEW.staff_id
    AND slj.is_primary = true
  ) THEN
    RAISE EXCEPTION 'Staff member is not eligible for this benefit';
  END IF;

  -- Check frequency limits
  IF NOT validate_benefit_claim_frequency(NEW.staff_id, NEW.benefit_id, NEW.claim_date::date) THEN
    RAISE EXCEPTION 'Claim frequency limit exceeded for this benefit';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop and recreate the trigger
DROP TRIGGER IF EXISTS validate_benefit_claim_trigger ON benefit_claims;
CREATE TRIGGER validate_benefit_claim_trigger
  BEFORE INSERT ON benefit_claims
  FOR EACH ROW
  EXECUTE FUNCTION validate_benefit_claim();