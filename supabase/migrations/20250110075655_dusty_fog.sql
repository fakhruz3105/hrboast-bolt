-- Drop existing policies
DROP POLICY IF EXISTS "role_mappings_select" ON role_mappings;
DROP POLICY IF EXISTS "role_mappings_insert" ON role_mappings;
DROP POLICY IF EXISTS "role_mappings_update" ON role_mappings;
DROP POLICY IF EXISTS "role_mappings_delete" ON role_mappings;

-- Create new RLS policies
CREATE POLICY "role_mappings_select"
  ON role_mappings FOR SELECT
  USING (true);

CREATE POLICY "role_mappings_insert"
  ON role_mappings FOR INSERT
  WITH CHECK (true);

CREATE POLICY "role_mappings_update"
  ON role_mappings FOR UPDATE
  USING (true);

CREATE POLICY "role_mappings_delete"
  ON role_mappings FOR DELETE
  USING (true);

-- Create function to safely update role mappings
CREATE OR REPLACE FUNCTION update_role_mapping(
  p_staff_level_id uuid,
  p_role text
)
RETURNS void AS $$
BEGIN
  INSERT INTO role_mappings (staff_level_id, role)
  VALUES (p_staff_level_id, p_role)
  ON CONFLICT (staff_level_id) 
  DO UPDATE SET role = EXCLUDED.role;

  -- Update staff roles based on their primary level
  UPDATE staff s
  SET role_id = rm.id
  FROM staff_levels_junction slj
  JOIN role_mappings rm ON rm.staff_level_id = slj.level_id
  WHERE slj.staff_id = s.id
  AND slj.is_primary = true
  AND slj.level_id = p_staff_level_id;
END;
$$ LANGUAGE plpgsql;