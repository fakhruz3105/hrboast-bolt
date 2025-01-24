-- Drop existing function
DROP FUNCTION IF EXISTS delete_department;

-- Create function with unambiguous parameter name
CREATE OR REPLACE FUNCTION delete_department(p_department_id uuid)
RETURNS boolean AS $$
BEGIN
  -- Check if department has any staff
  IF EXISTS (
    SELECT 1 FROM staff 
    WHERE department_id = p_department_id
  ) THEN
    RAISE EXCEPTION 'Cannot delete department that has staff members assigned to it';
  END IF;

  -- If no staff, delete the department
  DELETE FROM departments WHERE id = p_department_id;
  RETURN true;
END;
$$ LANGUAGE plpgsql;