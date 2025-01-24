/*
  # Create departments and staff tables with relationships

  1. New Tables
    - `departments`
      - `id` (uuid, primary key)
      - `name` (text, unique)
      - `description` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

    - `staff`
      - `id` (uuid, primary key)
      - `first_name` (text)
      - `last_name` (text)
      - `email` (text, unique)
      - `department_id` (uuid, foreign key)
      - `level_id` (uuid, foreign key)
      - `join_date` (date)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Relationships
    - Staff belongs to Department (many-to-one)
    - Staff belongs to StaffLevel (many-to-one)
    - Department has many Staff (one-to-many)
    - StaffLevel has many Staff (one-to-many)

  3. Security
    - Enable RLS on all tables
    - Add policies for read access
*/

-- Create departments table
CREATE TABLE IF NOT EXISTS departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create staff table with relationships
CREATE TABLE IF NOT EXISTS staff (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name text NOT NULL,
  last_name text NOT NULL,
  email text UNIQUE NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  join_date date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users on departments"
  ON departments FOR SELECT
  USING (true);

CREATE POLICY "Enable all access for all users on departments"
  ON departments FOR ALL
  USING (true);

CREATE POLICY "Enable read access for all users on staff"
  ON staff FOR SELECT
  USING (true);

CREATE POLICY "Enable all access for all users on staff"
  ON staff FOR ALL
  USING (true);

-- Insert default departments
INSERT INTO departments (name, description) VALUES
  ('Executive', 'Company leadership and strategic planning'),
  ('Human Resources', 'HR management and employee relations'),
  ('Engineering', 'Software development and technical operations'),
  ('Marketing', 'Marketing and brand management'),
  ('Sales', 'Sales and business development'),
  ('Finance', 'Financial planning and accounting')
ON CONFLICT (name) DO NOTHING;