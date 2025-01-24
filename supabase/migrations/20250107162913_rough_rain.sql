-- Drop existing policies
DROP POLICY IF EXISTS "staff_forms_select_policy" ON staff_interview_forms;
DROP POLICY IF EXISTS "staff_forms_insert_policy" ON staff_interview_forms;

-- Drop and recreate the foreign key with cascade delete
ALTER TABLE staff_interview_forms 
DROP CONSTRAINT IF EXISTS staff_interview_forms_interview_id_fkey;

ALTER TABLE staff_interview_forms
ADD CONSTRAINT staff_interview_forms_interview_id_fkey
FOREIGN KEY (interview_id)
REFERENCES staff_interviews(id)
ON DELETE CASCADE;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_staff_interview_forms_interview_id 
ON staff_interview_forms(interview_id);

-- Create new RLS policies
CREATE POLICY "staff_interview_forms_select"
  ON staff_interview_forms FOR SELECT
  USING (true);

CREATE POLICY "staff_interview_forms_insert"
  ON staff_interview_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "staff_interview_forms_delete"
  ON staff_interview_forms FOR DELETE
  USING (true);

-- Add trigger to update staff_interviews status
CREATE OR REPLACE FUNCTION update_interview_status()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE staff_interviews
  SET status = 'completed'
  WHERE id = NEW.interview_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_interview_status_trigger ON staff_interview_forms;
CREATE TRIGGER update_interview_status_trigger
  AFTER INSERT ON staff_interview_forms
  FOR EACH ROW
  EXECUTE FUNCTION update_interview_status();

-- Enable RLS
ALTER TABLE staff_interview_forms ENABLE ROW LEVEL SECURITY;