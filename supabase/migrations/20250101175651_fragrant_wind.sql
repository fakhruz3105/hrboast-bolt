/*
  # Fix Staff Interviews Table

  1. Changes
    - Drop and recreate staff_interviews table with proper structure
    - Add RLS policies
    - Add indexes for better performance
*/

-- Drop existing table if exists
DROP TABLE IF EXISTS staff_interviews CASCADE;

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
CREATE INDEX idx_staff_interviews_department ON staff_interviews(department_id);
CREATE INDEX idx_staff_interviews_level ON staff_interviews(level_id);
CREATE INDEX idx_staff_interviews_status ON staff_interviews(status);
CREATE INDEX idx_staff_interviews_email ON staff_interviews(email);

-- Enable RLS
ALTER TABLE staff_interviews ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users"
  ON staff_interviews FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON staff_interviews FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users"
  ON staff_interviews FOR UPDATE
  USING (true)
  WITH CHECK (true);