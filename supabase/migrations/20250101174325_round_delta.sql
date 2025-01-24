-- Create staff interview form responses table
CREATE TABLE staff_interview_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_id uuid REFERENCES staff_interviews(id) ON DELETE CASCADE,
  personal_info jsonb NOT NULL,
  education_history jsonb NOT NULL,
  work_experience jsonb NOT NULL,
  emergency_contacts jsonb NOT NULL,
  submitted_at timestamptz DEFAULT now(),
  UNIQUE(interview_id)
);

-- Enable RLS
ALTER TABLE staff_interview_forms ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users on staff_interview_forms"
  ON staff_interview_forms FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users on staff_interview_forms"
  ON staff_interview_forms FOR INSERT
  WITH CHECK (true);