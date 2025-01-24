-- Drop existing policies
DROP POLICY IF EXISTS "evaluation_responses_select" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_insert" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_update" ON evaluation_responses;

-- Create new RLS policies for evaluation_responses
CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (
    -- Staff can see their own evaluations
    staff_id = auth.uid() OR
    -- Managers can see evaluations they're assigned to
    manager_id = auth.uid() OR
    -- Admins and HR can see all evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (
    -- Only admins and HR can create evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "evaluation_responses_update"
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
CREATE POLICY "evaluation_responses_delete"
  ON evaluation_responses FOR DELETE
  USING (
    -- Only admins and HR can delete evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

-- Enable RLS
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;