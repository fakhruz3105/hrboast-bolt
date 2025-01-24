-- Create junction table for staff and departments
CREATE TABLE staff_departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, department_id)
);

-- Create indexes for better performance
CREATE INDEX idx_staff_departments_staff ON staff_departments(staff_id);
CREATE INDEX idx_staff_departments_department ON staff_departments(department_id);
CREATE INDEX idx_staff_departments_primary ON staff_departments(is_primary);

-- Enable RLS
ALTER TABLE staff_departments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "staff_departments_select"
  ON staff_departments FOR SELECT
  USING (true);

CREATE POLICY "staff_departments_insert"
  ON staff_departments FOR INSERT
  WITH CHECK (true);

CREATE POLICY "staff_departments_update"
  ON staff_departments FOR UPDATE
  USING (true);

CREATE POLICY "staff_departments_delete"
  ON staff_departments FOR DELETE
  USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_staff_departments_timestamp
  BEFORE UPDATE ON staff_departments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add trigger to ensure only one primary department per staff
CREATE OR REPLACE FUNCTION ensure_single_primary_department()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_primary THEN
    UPDATE staff_departments
    SET is_primary = false
    WHERE staff_id = NEW.staff_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_single_primary_department_trigger
  BEFORE INSERT OR UPDATE ON staff_departments
  FOR EACH ROW
  EXECUTE FUNCTION ensure_single_primary_department();

-- Migrate existing staff department relationships
INSERT INTO staff_departments (staff_id, department_id, is_primary)
SELECT id, department_id, true
FROM staff
WHERE department_id IS NOT NULL;

-- Remove department_id from staff table
ALTER TABLE staff
DROP COLUMN department_id;