-- First drop the existing foreign key constraint
ALTER TABLE exit_interviews
DROP CONSTRAINT IF EXISTS exit_interviews_staff_id_fkey;

-- Add new foreign key constraint with ON DELETE CASCADE
ALTER TABLE exit_interviews
ADD CONSTRAINT exit_interviews_staff_id_fkey
FOREIGN KEY (staff_id)
REFERENCES staff(id)
ON DELETE CASCADE;

-- Create function to safely delete staff
CREATE OR REPLACE FUNCTION delete_staff(p_staff_id uuid)
RETURNS boolean AS $$
BEGIN
  -- Delete the staff member and all related records will be deleted via cascade
  DELETE FROM staff WHERE id = p_staff_id;
  RETURN true;
EXCEPTION
  WHEN foreign_key_violation THEN
    RAISE EXCEPTION 'Cannot delete staff member due to existing dependencies';
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Failed to delete staff member: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;