-- First drop the existing foreign key constraint
ALTER TABLE staff
DROP CONSTRAINT IF EXISTS staff_department_id_fkey;

-- Add new foreign key constraint with ON DELETE RESTRICT
ALTER TABLE staff
ADD CONSTRAINT staff_department_id_fkey
FOREIGN KEY (department_id)
REFERENCES departments(id)
ON DELETE RESTRICT;

-- Create function to safely delete department
CREATE OR REPLACE FUNCTION delete_department(department_id uuid)
RETURNS boolean AS $$
BEGIN
  -- Check if department has any staff
  IF EXISTS (
    SELECT 1 FROM staff 
    WHERE department_id = $1
  ) THEN
    RAISE EXCEPTION 'Cannot delete department that has staff members assigned to it';
  END IF;

  -- If no staff, delete the department
  DELETE FROM departments WHERE id = $1;
  RETURN true;
END;
$$ LANGUAGE plpgsql;