-- Drop existing policies safely
DO $$ 
BEGIN
  -- Drop evaluation_responses policies if they exist
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses'
  ) THEN
    DROP POLICY IF EXISTS "evaluation_responses_select" ON evaluation_responses;
    DROP POLICY IF EXISTS "evaluation_responses_insert" ON evaluation_responses;
    DROP POLICY IF EXISTS "evaluation_responses_update" ON evaluation_responses;
    DROP POLICY IF EXISTS "evaluation_responses_delete" ON evaluation_responses;
  END IF;
END $$;

-- Create new RLS policies with simpler rules
CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (true);  -- Allow all authenticated users to view evaluations

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create evaluations

CREATE POLICY "evaluation_responses_update"
  ON evaluation_responses FOR UPDATE
  USING (true);  -- Allow all authenticated users to update evaluations

CREATE POLICY "evaluation_responses_delete"
  ON evaluation_responses FOR DELETE
  USING (true);  -- Allow all authenticated users to delete evaluations

-- Enable RLS
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;