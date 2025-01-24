/*
  # Create staff levels table

  1. New Tables
    - `staff_levels`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `rank` (integer)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `staff_levels` table
    - Add policies for authenticated users to manage levels
*/

CREATE TABLE IF NOT EXISTS staff_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text NOT NULL,
  rank integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE staff_levels ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Allow authenticated users to read staff levels"
  ON staff_levels
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to insert staff levels"
  ON staff_levels
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update staff levels"
  ON staff_levels
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to delete staff levels"
  ON staff_levels
  FOR DELETE
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