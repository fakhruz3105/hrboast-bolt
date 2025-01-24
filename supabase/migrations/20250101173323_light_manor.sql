/*
  # Fix Staff Schema and Relationships

  1. Changes
    - Add foreign key constraints with proper ON DELETE behavior
    - Add indexes for better query performance
    - Add validation triggers for staff status changes
    - Add updated_at trigger

  2. Security
    - Enable RLS
    - Add policies for CRUD operations
*/

-- Create trigger function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger function to validate status changes
CREATE OR REPLACE FUNCTION validate_staff_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Prevent changing from resigned back to other statuses
  IF OLD.status = 'resigned' AND NEW.status != 'resigned' THEN
    RAISE EXCEPTION 'Cannot change status from resigned to %', NEW.status;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers to staff table
DROP TRIGGER IF EXISTS set_updated_at ON staff;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON staff
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS validate_status_change ON staff;
CREATE TRIGGER validate_status_change
  BEFORE UPDATE ON staff
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION validate_staff_status_change();

-- Add foreign key constraints if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'staff_department_id_fkey'
  ) THEN
    ALTER TABLE staff
    ADD CONSTRAINT staff_department_id_fkey
    FOREIGN KEY (department_id)
    REFERENCES departments(id)
    ON DELETE RESTRICT;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'staff_level_id_fkey'
  ) THEN
    ALTER TABLE staff
    ADD CONSTRAINT staff_level_id_fkey
    FOREIGN KEY (level_id)
    REFERENCES staff_levels(id)
    ON DELETE RESTRICT;
  END IF;
END $$;

-- Create or replace indexes
DROP INDEX IF EXISTS staff_department_id_idx;
CREATE INDEX staff_department_id_idx ON staff(department_id);

DROP INDEX IF EXISTS staff_level_id_idx;
CREATE INDEX staff_level_id_idx ON staff(level_id);

DROP INDEX IF EXISTS staff_email_idx;
CREATE INDEX staff_email_idx ON staff(email);

DROP INDEX IF EXISTS staff_status_idx;
CREATE INDEX staff_status_idx ON staff(status);

-- Recreate RLS policies with better names and conditions
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "staff_select" ON staff;
CREATE POLICY "staff_select"
  ON staff FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "staff_insert" ON staff;
CREATE POLICY "staff_insert"
  ON staff FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "staff_update" ON staff;
CREATE POLICY "staff_update"
  ON staff FOR UPDATE
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "staff_delete" ON staff;
CREATE POLICY "staff_delete"
  ON staff FOR DELETE
  USING (true);