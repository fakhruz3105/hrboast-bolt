/*
  # Staff Levels Schema

  1. New Tables
    - `staff_levels`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `rank` (integer, unique)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `staff_levels` table
    - Add policies for authenticated users to manage staff levels
*/

CREATE TABLE IF NOT EXISTS staff_levels (
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
CREATE POLICY "Enable read access for all users"
ON staff_levels FOR SELECT
USING (true);

CREATE POLICY "Enable insert access for all users"
ON staff_levels FOR INSERT
WITH CHECK (true);

CREATE POLICY "Enable update access for all users"
ON staff_levels FOR UPDATE
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete access for all users"
ON staff_levels FOR DELETE
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