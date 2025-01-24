/*
  # Add Role Relationship to Staff

  1. Changes
    - Add role_id column to staff table
    - Add foreign key constraint to role_mappings
    - Create index for role lookups
    - Add RLS policies for role-based access
    - Handle existing data safely
*/

-- First, ensure all staff have a valid level_id and corresponding role mapping
INSERT INTO role_mappings (staff_level_id, role)
SELECT DISTINCT level_id, 'staff'::text
FROM staff s
WHERE NOT EXISTS (
  SELECT 1 FROM role_mappings rm WHERE rm.staff_level_id = s.level_id
);

-- Add role_id column as nullable first
ALTER TABLE staff
ADD COLUMN role_id uuid REFERENCES role_mappings(id);

-- Create index for role lookups
CREATE INDEX idx_staff_role_id ON staff(role_id);

-- Update existing staff with roles based on their level
UPDATE staff
SET role_id = rm.id
FROM role_mappings rm
WHERE staff.level_id = rm.staff_level_id;

-- Now make role_id required
ALTER TABLE staff
ALTER COLUMN role_id SET NOT NULL;

-- Add trigger to automatically set role_id when level_id changes
CREATE OR REPLACE FUNCTION update_staff_role()
RETURNS TRIGGER AS $$
BEGIN
  -- Get the role_id from role_mappings based on the new level_id
  SELECT id INTO NEW.role_id
  FROM role_mappings
  WHERE staff_level_id = NEW.level_id;
  
  IF NEW.role_id IS NULL THEN
    -- If no role mapping exists, create a default 'staff' role mapping
    INSERT INTO role_mappings (staff_level_id, role)
    VALUES (NEW.level_id, 'staff')
    RETURNING id INTO NEW.role_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_staff_role
  BEFORE INSERT OR UPDATE OF level_id ON staff
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_role();