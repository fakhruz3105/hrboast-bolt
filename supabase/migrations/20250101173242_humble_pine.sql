/*
  # Fix Staff Table Schema

  1. Changes
    - Recreate staff table with correct structure
    - Add proper foreign key constraints
    - Add RLS policies
    - Add indexes for better performance
*/

-- Drop existing staff table
DROP TABLE IF EXISTS staff;

-- Create staff table with correct structure
CREATE TABLE staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone_number text NOT NULL,
  email text UNIQUE NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  join_date date NOT NULL DEFAULT CURRENT_DATE,
  status staff_status NOT NULL DEFAULT 'probation',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX staff_department_id_idx ON staff(department_id);
CREATE INDEX staff_level_id_idx ON staff(level_id);
CREATE INDEX staff_email_idx ON staff(email);
CREATE INDEX staff_status_idx ON staff(status);

-- Enable RLS
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users on staff"
  ON staff FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users on staff"
  ON staff FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users on staff"
  ON staff FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete access for all users on staff"
  ON staff FOR DELETE
  USING (true);