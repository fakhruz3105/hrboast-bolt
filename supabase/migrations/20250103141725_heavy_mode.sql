-- Update evaluation_forms table structure
ALTER TABLE evaluation_forms
DROP COLUMN IF EXISTS department_id,
DROP COLUMN IF EXISTS level_id;

-- Update RLS policies
DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_forms_insert" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_responses_select" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_insert" ON evaluation_responses;

-- Create new RLS policies
CREATE POLICY "evaluation_forms_select"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert"
  ON evaluation_forms FOR INSERT
  WITH CHECK (auth.role() IN ('admin', 'hr'));

CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (
    auth.role() IN ('admin', 'hr') OR 
    staff_id = auth.uid() OR 
    manager_id = auth.uid()
  );

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (auth.role() IN ('admin', 'hr'));

CREATE POLICY "evaluation_responses_update"
  ON evaluation_responses FOR UPDATE
  USING (
    auth.role() IN ('admin', 'hr') OR 
    (staff_id = auth.uid() AND status = 'pending') OR
    (manager_id = auth.uid() AND status = 'pending')
  );