-- Drop existing policies if they exist
DROP POLICY IF EXISTS "benefits_select" ON benefits;
DROP POLICY IF EXISTS "benefits_insert" ON benefits;
DROP POLICY IF EXISTS "benefits_update" ON benefits;
DROP POLICY IF EXISTS "benefits_delete" ON benefits;

-- Enable RLS
ALTER TABLE benefits ENABLE ROW LEVEL SECURITY;

-- Create new RLS policies
CREATE POLICY "benefits_select"
  ON benefits FOR SELECT
  USING (true);  -- Allow all authenticated users to view benefits

CREATE POLICY "benefits_insert"
  ON benefits FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to insert benefits

CREATE POLICY "benefits_update"
  ON benefits FOR UPDATE
  USING (true);  -- Allow all authenticated users to update benefits

CREATE POLICY "benefits_delete"
  ON benefits FOR DELETE
  USING (true);  -- Allow all authenticated users to delete benefits

-- Ensure policies are applied to benefit_eligibility table as well
DROP POLICY IF EXISTS "benefit_eligibility_select" ON benefit_eligibility;
DROP POLICY IF EXISTS "benefit_eligibility_insert" ON benefit_eligibility;
DROP POLICY IF EXISTS "benefit_eligibility_delete" ON benefit_eligibility;

CREATE POLICY "benefit_eligibility_select"
  ON benefit_eligibility FOR SELECT
  USING (true);

CREATE POLICY "benefit_eligibility_insert"
  ON benefit_eligibility FOR INSERT
  WITH CHECK (true);

CREATE POLICY "benefit_eligibility_delete"
  ON benefit_eligibility FOR DELETE
  USING (true);