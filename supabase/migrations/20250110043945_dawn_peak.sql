-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "staff_levels_junction_select" ON staff_levels_junction;
  DROP POLICY IF EXISTS "staff_levels_junction_insert" ON staff_levels_junction;
  DROP POLICY IF EXISTS "staff_levels_junction_update" ON staff_levels_junction;
  DROP POLICY IF EXISTS "staff_levels_junction_delete" ON staff_levels_junction;
END $$;

-- Create simplified RLS policies
CREATE POLICY "staff_levels_junction_select_new"
  ON staff_levels_junction FOR SELECT
  USING (true);

CREATE POLICY "staff_levels_junction_insert_new"
  ON staff_levels_junction FOR INSERT
  WITH CHECK (true);

CREATE POLICY "staff_levels_junction_update_new"
  ON staff_levels_junction FOR UPDATE
  USING (true);

CREATE POLICY "staff_levels_junction_delete_new"
  ON staff_levels_junction FOR DELETE
  USING (true);

-- Create function to get staff's primary level
CREATE OR REPLACE FUNCTION get_staff_primary_level(p_staff_id uuid)
RETURNS TABLE (
  level_id uuid,
  level_name text,
  level_rank integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sl.id as level_id,
    sl.name as level_name,
    sl.rank as level_rank
  FROM staff_levels_junction slj
  JOIN staff_levels sl ON sl.id = slj.level_id
  WHERE slj.staff_id = p_staff_id
  AND slj.is_primary = true;
END;
$$ LANGUAGE plpgsql;

-- Create function to get all staff levels
CREATE OR REPLACE FUNCTION get_staff_levels(p_staff_id uuid)
RETURNS TABLE (
  level_id uuid,
  level_name text,
  level_rank integer,
  is_primary boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    sl.id as level_id,
    sl.name as level_name,
    sl.rank as level_rank,
    slj.is_primary
  FROM staff_levels_junction slj
  JOIN staff_levels sl ON sl.id = slj.level_id
  WHERE slj.staff_id = p_staff_id
  ORDER BY slj.is_primary DESC, sl.rank;
END;
$$ LANGUAGE plpgsql;

-- Create function to update staff role based on primary level
CREATE OR REPLACE FUNCTION update_staff_role_from_level()
RETURNS TRIGGER AS $$
BEGIN
  -- Get the role_id from role_mappings based on the primary level
  IF NEW.is_primary THEN
    UPDATE staff s
    SET role_id = rm.id
    FROM role_mappings rm
    WHERE rm.staff_level_id = NEW.level_id
    AND s.id = NEW.staff_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_staff_role_trigger ON staff_levels_junction;

-- Create trigger for role updates
CREATE TRIGGER update_staff_role_trigger
  AFTER INSERT OR UPDATE OF is_primary ON staff_levels_junction
  FOR EACH ROW
  EXECUTE FUNCTION update_staff_role_from_level();