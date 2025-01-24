-- First drop the trigger that depends on level_id
DROP TRIGGER IF EXISTS set_staff_role ON staff;
DROP FUNCTION IF EXISTS update_staff_role;

-- Create junction table for staff and levels
CREATE TABLE staff_levels_junction (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  is_primary boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(staff_id, level_id)
);

-- Create indexes for better performance
CREATE INDEX idx_staff_levels_junction_staff ON staff_levels_junction(staff_id);
CREATE INDEX idx_staff_levels_junction_level ON staff_levels_junction(level_id);
CREATE INDEX idx_staff_levels_junction_primary ON staff_levels_junction(is_primary);

-- Enable RLS
ALTER TABLE staff_levels_junction ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "staff_levels_junction_select"
  ON staff_levels_junction FOR SELECT
  USING (true);

CREATE POLICY "staff_levels_junction_insert"
  ON staff_levels_junction FOR INSERT
  WITH CHECK (true);

CREATE POLICY "staff_levels_junction_update"
  ON staff_levels_junction FOR UPDATE
  USING (true);

CREATE POLICY "staff_levels_junction_delete"
  ON staff_levels_junction FOR DELETE
  USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_staff_levels_junction_timestamp
  BEFORE UPDATE ON staff_levels_junction
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add trigger to ensure only one primary level per staff
CREATE OR REPLACE FUNCTION ensure_single_primary_level()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_primary THEN
    UPDATE staff_levels_junction
    SET is_primary = false
    WHERE staff_id = NEW.staff_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_single_primary_level_trigger
  BEFORE INSERT OR UPDATE ON staff_levels_junction
  FOR EACH ROW
  EXECUTE FUNCTION ensure_single_primary_level();

-- Migrate existing staff level relationships
INSERT INTO staff_levels_junction (staff_id, level_id, is_primary)
SELECT id, level_id, true
FROM staff
WHERE level_id IS NOT NULL;

-- Create new function to handle role updates based on primary level
CREATE OR REPLACE FUNCTION update_staff_role_from_levels()
RETURNS TRIGGER AS $$
BEGIN
  -- Get the role_id from role_mappings based on the primary level
  UPDATE staff s
  SET role_id = rm.id
  FROM staff_levels_junction slj
  JOIN role_mappings rm ON rm.staff_level_id = slj.level_id
  WHERE s.id = slj.staff_id
  AND slj.is_primary = true
  AND slj.staff_id = NEW.staff_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for role updates
CREATE TRIGGER update_staff_role_from_levels
  AFTER INSERT OR UPDATE ON staff_levels_junction
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_role_from_levels();

-- Now we can safely remove the level_id column
ALTER TABLE staff DROP COLUMN level_id;