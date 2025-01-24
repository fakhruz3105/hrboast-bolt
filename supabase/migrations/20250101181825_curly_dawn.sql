-- Create role mappings table
CREATE TABLE role_mappings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'hr', 'staff')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_level_id)
);

-- Create indexes
CREATE INDEX idx_role_mappings_staff_level ON role_mappings(staff_level_id);
CREATE INDEX idx_role_mappings_role ON role_mappings(role);

-- Enable RLS
ALTER TABLE role_mappings ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users"
  ON role_mappings FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON role_mappings FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable delete access for all users"
  ON role_mappings FOR DELETE
  USING (true);

-- Insert default mappings
INSERT INTO role_mappings (staff_level_id, role)
VALUES
  ((SELECT id FROM staff_levels WHERE name = 'Director'), 'admin'),
  ((SELECT id FROM staff_levels WHERE name = 'C-Suite'), 'admin'),
  ((SELECT id FROM staff_levels WHERE name = 'HR'), 'hr'),
  ((SELECT id FROM staff_levels WHERE name = 'Staff'), 'staff'),
  ((SELECT id FROM staff_levels WHERE name = 'Practical'), 'staff')
ON CONFLICT (staff_level_id) DO NOTHING;