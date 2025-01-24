/*
  # Fix authentication and database access

  1. Changes
    - Drop and recreate staff_levels table with proper RLS
    - Add proper indexes and constraints
    - Set up RLS policies for authenticated users
*/

-- Recreate staff_levels table with proper structure
DROP TABLE IF EXISTS staff_levels;

CREATE TABLE staff_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  rank integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(name),
  UNIQUE(rank)
);

-- Enable RLS
ALTER TABLE staff_levels ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for authenticated users"
ON staff_levels FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert access for authenticated users"
ON staff_levels FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Enable update access for authenticated users"
ON staff_levels FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete access for authenticated users"
ON staff_levels FOR DELETE
TO authenticated
USING (true);

-- Insert default levels
INSERT INTO staff_levels (name, description, rank)
VALUES 
  ('Director', 'Company leadership and strategic direction', 1),
  ('C-Suite', 'Executive management and decision making', 2),
  ('HOD/Manager', 'Departmental management and team leadership', 3),
  ('HR', 'Human resources management and administration', 4),
  ('Staff', 'Regular full-time employees', 5),
  ('Practical', 'Interns and temporary staff', 6)
ON CONFLICT (name) DO NOTHING;