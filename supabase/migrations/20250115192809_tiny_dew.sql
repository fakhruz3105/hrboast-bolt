-- Create function to get role ID based on staff level
CREATE OR REPLACE FUNCTION get_role_id_for_level(p_level_id uuid)
RETURNS uuid AS $$
DECLARE
  v_role_id uuid;
BEGIN
  SELECT id INTO v_role_id
  FROM role_mappings
  WHERE staff_level_id = p_level_id;

  IF v_role_id IS NULL THEN
    -- If no role mapping exists, create a default 'staff' role mapping
    INSERT INTO role_mappings (staff_level_id, role)
    VALUES (p_level_id, 'staff')
    RETURNING id INTO v_role_id;
  END IF;

  RETURN v_role_id;
END;
$$ LANGUAGE plpgsql;

-- Create trigger function to update role_id when primary level changes
CREATE OR REPLACE FUNCTION update_staff_role_from_level()
RETURNS TRIGGER AS $$
DECLARE
  v_role_id uuid;
BEGIN
  IF NEW.is_primary THEN
    -- Get role_id for the new primary level
    SELECT get_role_id_for_level(NEW.level_id) INTO v_role_id;

    -- Update staff role_id
    UPDATE staff
    SET role_id = v_role_id
    WHERE id = NEW.staff_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to update role_id when primary level changes
DROP TRIGGER IF EXISTS update_staff_role_trigger ON staff_levels_junction;
CREATE TRIGGER update_staff_role_trigger
  AFTER INSERT OR UPDATE OF is_primary ON staff_levels_junction
  FOR EACH ROW
  WHEN (NEW.is_primary = true)
  EXECUTE FUNCTION update_staff_role_from_level();

-- Fix any staff records with null role_id
DO $$
DECLARE
  v_staff RECORD;
  v_role_id uuid;
BEGIN
  FOR v_staff IN 
    SELECT s.id, slj.level_id
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    WHERE slj.is_primary = true
    AND s.role_id IS NULL
  LOOP
    -- Get role_id for the staff's primary level
    SELECT get_role_id_for_level(v_staff.level_id) INTO v_role_id;

    -- Update staff role_id
    UPDATE staff
    SET role_id = v_role_id
    WHERE id = v_staff.id;
  END LOOP;
END $$;