-- Create department default levels table
CREATE TABLE department_default_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(department_id)
);

-- Create indexes
CREATE INDEX idx_dept_default_levels_department ON department_default_levels(department_id);
CREATE INDEX idx_dept_default_levels_level ON department_default_levels(level_id);

-- Enable RLS
ALTER TABLE department_default_levels ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "department_default_levels_select"
  ON department_default_levels FOR SELECT
  USING (true);

CREATE POLICY "department_default_levels_insert"
  ON department_default_levels FOR INSERT
  WITH CHECK (true);

CREATE POLICY "department_default_levels_update"
  ON department_default_levels FOR UPDATE
  USING (true);

CREATE POLICY "department_default_levels_delete"
  ON department_default_levels FOR DELETE
  USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_department_default_levels_timestamp
  BEFORE UPDATE ON department_default_levels
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();