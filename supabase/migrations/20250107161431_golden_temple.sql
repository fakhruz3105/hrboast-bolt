-- Drop existing foreign key constraint if exists
ALTER TABLE staff_interview_forms 
DROP CONSTRAINT IF EXISTS staff_interview_forms_interview_id_fkey;

-- Recreate foreign key with cascade delete
ALTER TABLE staff_interview_forms
ADD CONSTRAINT staff_interview_forms_interview_id_fkey
FOREIGN KEY (interview_id)
REFERENCES staff_interviews(id)
ON DELETE CASCADE;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_staff_interview_forms_interview_id 
ON staff_interview_forms(interview_id);

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "staff_interview_forms_select" ON staff_interview_forms;
DROP POLICY IF EXISTS "staff_interview_forms_insert" ON staff_interview_forms;
DROP POLICY IF EXISTS "Enable read access for all users" ON staff_interview_forms;
DROP POLICY IF EXISTS "Enable insert access for all users" ON staff_interview_forms;

-- Create new RLS policies
CREATE POLICY "staff_interview_forms_select_policy"
  ON staff_interview_forms FOR SELECT
  USING (true);

CREATE POLICY "staff_interview_forms_insert_policy"
  ON staff_interview_forms FOR INSERT
  WITH CHECK (true);