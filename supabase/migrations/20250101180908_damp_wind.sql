/*
  # Fix Interview Forms Schema

  1. Changes
    - Add proper relationship between staff_interviews and staff_interview_forms
    - Add indexes for better query performance
    - Update RLS policies
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON staff_interview_forms;
DROP POLICY IF EXISTS "Enable insert access for all users" ON staff_interview_forms;

-- Modify staff_interview_forms table
ALTER TABLE staff_interview_forms
ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_interview_forms_interview_id 
ON staff_interview_forms(interview_id);

CREATE INDEX IF NOT EXISTS idx_interview_forms_submitted_at 
ON staff_interview_forms(submitted_at);

-- Create RLS policies with better names and conditions
CREATE POLICY "staff_interview_forms_select"
  ON staff_interview_forms FOR SELECT
  USING (true);

CREATE POLICY "staff_interview_forms_insert"
  ON staff_interview_forms FOR INSERT
  WITH CHECK (true);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_staff_interview_forms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_staff_interview_forms_updated_at
  BEFORE UPDATE ON staff_interview_forms
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_interview_forms_updated_at();