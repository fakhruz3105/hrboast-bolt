-- Drop existing function first
DROP FUNCTION IF EXISTS get_staff_details(uuid);

-- Create junction table for staff and departments if it doesn't exist
CREATE TABLE IF NOT EXISTS staff_departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, department_id)
);

-- Create junction table for staff and levels if it doesn't exist
CREATE TABLE IF NOT EXISTS staff_levels_junction (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, level_id)
);

-- Enable RLS
ALTER TABLE staff_departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff_levels_junction ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users on staff_departments"
  ON staff_departments FOR SELECT
  USING (true);

CREATE POLICY "Enable read access for all users on staff_levels_junction"
  ON staff_levels_junction FOR SELECT
  USING (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_staff_departments_staff ON staff_departments(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_departments_department ON staff_departments(department_id);
CREATE INDEX IF NOT EXISTS idx_staff_departments_primary ON staff_departments(is_primary);
CREATE INDEX IF NOT EXISTS idx_staff_levels_junction_staff ON staff_levels_junction(staff_id);
CREATE INDEX IF NOT EXISTS idx_staff_levels_junction_level ON staff_levels_junction(level_id);
CREATE INDEX IF NOT EXISTS idx_staff_levels_junction_primary ON staff_levels_junction(is_primary);

-- Create trigger functions for updated_at
CREATE OR REPLACE FUNCTION update_staff_departments_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_staff_levels_junction_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS set_staff_departments_timestamp ON staff_departments;
CREATE TRIGGER set_staff_departments_timestamp
  BEFORE UPDATE ON staff_departments
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_departments_timestamp();

DROP TRIGGER IF EXISTS set_staff_levels_junction_timestamp ON staff_levels_junction;
CREATE TRIGGER set_staff_levels_junction_timestamp
  BEFORE UPDATE ON staff_levels_junction
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_levels_junction_timestamp();

-- Create new function with updated return type
CREATE OR REPLACE FUNCTION get_staff_details(p_staff_id uuid)
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  phone_number text,
  join_date date,
  status text,
  primary_department_name text,
  other_department_names text[],
  primary_level_name text,
  other_level_names text[],
  role_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    s.email,
    s.phone_number,
    s.join_date,
    s.status::text,
    (
      SELECT d.name
      FROM staff_departments sd
      JOIN departments d ON d.id = sd.department_id
      WHERE sd.staff_id = s.id AND sd.is_primary = true
      LIMIT 1
    ) as primary_department_name,
    ARRAY(
      SELECT d.name
      FROM staff_departments sd
      JOIN departments d ON d.id = sd.department_id
      WHERE sd.staff_id = s.id AND sd.is_primary = false
      ORDER BY d.name
    ) as other_department_names,
    (
      SELECT sl.name
      FROM staff_levels_junction slj
      JOIN staff_levels sl ON sl.id = slj.level_id
      WHERE slj.staff_id = s.id AND slj.is_primary = true
      LIMIT 1
    ) as primary_level_name,
    ARRAY(
      SELECT sl.name
      FROM staff_levels_junction slj
      JOIN staff_levels sl ON sl.id = slj.level_id
      WHERE slj.staff_id = s.id AND slj.is_primary = false
      ORDER BY sl.name
    ) as other_level_names,
    rm.role as role_name
  FROM staff s
  LEFT JOIN role_mappings rm ON s.role_id = rm.id
  WHERE s.id = p_staff_id;
END;
$$ LANGUAGE plpgsql;