-- Drop existing function if it exists
DROP FUNCTION IF EXISTS update_staff_role_from_levels CASCADE;

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

-- Create trigger for role updates if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'update_staff_role_from_levels'
  ) THEN
    CREATE TRIGGER update_staff_role_from_levels
      AFTER INSERT OR UPDATE ON staff_levels_junction
      FOR EACH ROW
      EXECUTE FUNCTION update_staff_role_from_levels();
  END IF;
END $$;

-- Migrate any remaining staff-role relationships
DO $$
DECLARE
  v_staff RECORD;
  v_role_id uuid;
BEGIN
  FOR v_staff IN 
    SELECT s.id, s.role_id
    FROM staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM staff_levels_junction slj
      WHERE slj.staff_id = s.id
    )
  LOOP
    -- Get the default staff level ID
    SELECT rm.staff_level_id INTO v_role_id
    FROM role_mappings rm
    WHERE rm.id = v_staff.role_id;

    -- Create the junction record if we found a matching level
    IF v_role_id IS NOT NULL THEN
      INSERT INTO staff_levels_junction (staff_id, level_id, is_primary)
      VALUES (v_staff.id, v_role_id, true)
      ON CONFLICT (staff_id, level_id) DO NOTHING;
    END IF;
  END LOOP;
END $$;