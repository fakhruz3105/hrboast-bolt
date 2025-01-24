-- Drop existing policies safely
DO $$ 
BEGIN
  -- Drop evaluation_responses policies if they exist
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_select'
  ) THEN
    DROP POLICY "evaluation_responses_select" ON evaluation_responses;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_insert'
  ) THEN
    DROP POLICY "evaluation_responses_insert" ON evaluation_responses;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_update'
  ) THEN
    DROP POLICY "evaluation_responses_update" ON evaluation_responses;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_delete'
  ) THEN
    DROP POLICY "evaluation_responses_delete" ON evaluation_responses;
  END IF;
END $$;

-- Create new RLS policies for evaluation_responses
CREATE POLICY "evaluation_responses_select_new"
  ON evaluation_responses FOR SELECT
  USING (true);  -- Allow all authenticated users to view evaluations

CREATE POLICY "evaluation_responses_insert_new"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create evaluations

CREATE POLICY "evaluation_responses_update_new"
  ON evaluation_responses FOR UPDATE
  USING (
    -- Staff can update their own evaluations
    staff_id = auth.uid() OR
    -- Managers can update evaluations they're assigned to
    manager_id = auth.uid() OR
    -- Admins and HR can update all evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

-- Create policy for deleting evaluations
CREATE POLICY "evaluation_responses_delete_new"
  ON evaluation_responses FOR DELETE
  USING (
    -- Only admins and HR can delete evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );