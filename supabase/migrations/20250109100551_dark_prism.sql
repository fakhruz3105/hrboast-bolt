-- Create a function to get eligible benefits for a staff member
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
      WHERE be.benefit_id = b.id 
      AND be.level_id = (
        SELECT level_id 
        FROM staff 
        WHERE id = staff_uid
      )
    ) as is_eligible
  FROM benefits b
  WHERE b.status = true
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Create a function to check if a staff member can claim a benefit
CREATE OR REPLACE FUNCTION can_claim_benefit(staff_uid uuid, benefit_id uuid)
RETURNS boolean AS $$
DECLARE
  is_eligible boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1 
    FROM benefit_eligibility be
    JOIN staff s ON s.level_id = be.level_id
    WHERE s.id = staff_uid 
    AND be.benefit_id = benefit_id
  ) INTO is_eligible;
  
  RETURN is_eligible;
END;
$$ LANGUAGE plpgsql;

-- Update benefit claims policies
DROP POLICY IF EXISTS "benefit_claims_select" ON benefit_claims;
DROP POLICY IF EXISTS "benefit_claims_insert" ON benefit_claims;

CREATE POLICY "benefit_claims_select"
  ON benefit_claims FOR SELECT
  USING (
    staff_id = auth.uid() OR  -- Staff can see their own claims
    EXISTS (  -- Admins and HR can see all claims
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "benefit_claims_insert"
  ON benefit_claims FOR INSERT
  WITH CHECK (
    staff_id = auth.uid() AND  -- Staff can only claim for themselves
    can_claim_benefit(staff_id, benefit_id)  -- Must be eligible for the benefit
  );