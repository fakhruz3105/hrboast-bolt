-- Create benefit eligibility table
CREATE TABLE IF NOT EXISTS benefit_eligibility (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_id uuid REFERENCES benefits(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(benefit_id, level_id)
);

-- Enable RLS
ALTER TABLE benefit_eligibility ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "benefit_eligibility_select" ON benefit_eligibility FOR SELECT USING (true);
CREATE POLICY "benefit_eligibility_insert" ON benefit_eligibility FOR INSERT WITH CHECK (true);
CREATE POLICY "benefit_eligibility_delete" ON benefit_eligibility FOR DELETE USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_benefit_eligibility_timestamp
  BEFORE UPDATE ON benefit_eligibility
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add function to check benefit eligibility
CREATE OR REPLACE FUNCTION check_benefit_eligibility(staff_id uuid, benefit_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM staff s
    JOIN benefit_eligibility be ON s.level_id = be.level_id
    WHERE s.id = staff_id
    AND be.benefit_id = benefit_id
  );
END;
$$ LANGUAGE plpgsql;

-- Add trigger to validate benefit claims
CREATE OR REPLACE FUNCTION validate_benefit_claim()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT check_benefit_eligibility(NEW.staff_id, NEW.benefit_id) THEN
    RAISE EXCEPTION 'Staff member is not eligible for this benefit';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_benefit_claim_trigger
  BEFORE INSERT ON benefit_claims
  FOR EACH ROW
  EXECUTE FUNCTION validate_benefit_claim();