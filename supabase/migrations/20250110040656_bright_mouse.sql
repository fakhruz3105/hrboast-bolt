-- Drop existing function if it exists
DROP FUNCTION IF EXISTS delete_department;

-- Create function to safely delete department
CREATE OR REPLACE FUNCTION delete_department(p_department_id uuid)
RETURNS void AS $$
BEGIN
  -- Check if department has any staff
  IF EXISTS (
    SELECT 1 FROM staff_departments 
    WHERE department_id = p_department_id
  ) THEN
    RAISE EXCEPTION 'Cannot delete department that has staff members assigned to it';
  END IF;

  -- If no staff, delete the department
  DELETE FROM departments WHERE id = p_department_id;
END;
$$ LANGUAGE plpgsql;

-- Create RPC endpoint for the function
CREATE OR REPLACE FUNCTION delete_department_rpc(p_department_id uuid)
RETURNS void AS $$
BEGIN
  PERFORM delete_department(p_department_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;