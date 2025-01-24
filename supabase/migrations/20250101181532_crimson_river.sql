/*
  # Exit Interviews Schema

  1. New Tables
    - `exit_interviews`
      - `id` (uuid, primary key)
      - `staff_id` (uuid, references staff)
      - `reason` (text)
      - `detailed_reason` (text)
      - `last_working_date` (date)
      - `suggestions` (text)
      - `handover_notes` (text)
      - `exit_checklist` (jsonb)
      - `hr_approval` (approval_status)
      - `admin_approval` (approval_status)
      - `status` (exit_interview_status)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. New Types
    - `approval_status` enum
    - `exit_interview_status` enum

  3. Security
    - Enable RLS
    - Add policies for CRUD operations
*/

-- Create enum types
CREATE TYPE approval_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE exit_interview_status AS ENUM ('pending', 'approved', 'rejected');

-- Create exit interviews table
CREATE TABLE exit_interviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE RESTRICT,
  reason text NOT NULL,
  detailed_reason text NOT NULL,
  last_working_date date NOT NULL,
  suggestions text,
  handover_notes text NOT NULL,
  exit_checklist jsonb NOT NULL DEFAULT '{
    "returnedLaptop": false,
    "returnedAccessCard": false,
    "completedHandover": false,
    "clearedDues": false
  }',
  hr_approval approval_status NOT NULL DEFAULT 'pending',
  admin_approval approval_status NOT NULL DEFAULT 'pending',
  status exit_interview_status NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_last_working_date CHECK (last_working_date >= CURRENT_DATE)
);

-- Create indexes
CREATE INDEX idx_exit_interviews_staff_id ON exit_interviews(staff_id);
CREATE INDEX idx_exit_interviews_status ON exit_interviews(status);
CREATE INDEX idx_exit_interviews_hr_approval ON exit_interviews(hr_approval);
CREATE INDEX idx_exit_interviews_admin_approval ON exit_interviews(admin_approval);

-- Enable RLS
ALTER TABLE exit_interviews ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users"
  ON exit_interviews FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON exit_interviews FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users"
  ON exit_interviews FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create trigger for updated_at
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON exit_interviews
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO exit_interviews (
  staff_id,
  reason,
  detailed_reason,
  last_working_date,
  suggestions,
  handover_notes,
  exit_checklist,
  hr_approval,
  admin_approval,
  status
) 
SELECT
  id as staff_id,
  'better_opportunity',
  'Received an offer with better growth opportunities',
  CURRENT_DATE + interval '30 days',
  'Consider implementing more career development programs',
  'All ongoing projects documented in Confluence. Team is aware of handover plan.',
  '{
    "returnedLaptop": false,
    "returnedAccessCard": false,
    "completedHandover": false,
    "clearedDues": false
  }',
  'pending',
  'pending',
  'pending'
FROM staff
WHERE status = 'permanent'
LIMIT 3;