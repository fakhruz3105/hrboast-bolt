-- Drop existing functions
DROP FUNCTION IF EXISTS delete_department;
DROP FUNCTION IF EXISTS delete_department_rpc;

-- Create function to safely delete department
CREATE OR REPLACE FUNCTION delete_department(p_department_id uuid)
RETURNS void AS $$
BEGIN
  -- First check if there are any employee form requests
  IF EXISTS (
    SELECT 1 FROM employee_form_requests 
    WHERE department_id = p_department_id
  ) THEN
    -- Set department_id to NULL for any employee form requests
    UPDATE employee_form_requests
    SET department_id = NULL
    WHERE department_id = p_department_id;
  END IF;

  -- Remove all staff associations with this department
  DELETE FROM staff_departments 
  WHERE department_id = p_department_id;

  -- Delete the department
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