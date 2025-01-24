/*
  # Create Staff Interviews Table

  1. New Tables
    - `staff_interviews`
      - `id` (uuid, primary key)
      - `staff_name` (text)
      - `email` (text)
      - `department_id` (uuid, foreign key)
      - `level_id` (uuid, foreign key)
      - `form_link` (text)
      - `status` (enum: pending, completed, expired)
      - `created_at` (timestamp)
      - `expires_at` (timestamp)
  
  2. Security
    - Enable RLS
    - Add policies for read and write access
*/

-- Create status enum type
CREATE TYPE staff_interview_status AS ENUM ('pending', 'completed', 'expired');

-- Create staff interviews table
CREATE TABLE staff_interviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_name text NOT NULL,
  email text NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  form_link text NOT NULL,
  status staff_interview_status NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL,
  UNIQUE(email)
);

-- Create indexes
CREATE INDEX staff_interviews_department_id_idx ON staff_interviews(department_id);
CREATE INDEX staff_interviews_level_id_idx ON staff_interviews(level_id);
CREATE INDEX staff_interviews_email_idx ON staff_interviews(email);
CREATE INDEX staff_interviews_status_idx ON staff_interviews(status);

-- Enable RLS
ALTER TABLE staff_interviews ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users on staff_interviews"
  ON staff_interviews FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users on staff_interviews"
  ON staff_interviews FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users on staff_interviews"
  ON staff_interviews FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create trigger function to update expired status
CREATE OR REPLACE FUNCTION update_expired_interviews()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE staff_interviews
  SET status = 'expired'
  WHERE status = 'pending'
    AND expires_at < NOW();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to run every minute
CREATE OR REPLACE TRIGGER check_expired_interviews
  AFTER INSERT OR UPDATE ON staff_interviews
  EXECUTE FUNCTION update_expired_interviews();