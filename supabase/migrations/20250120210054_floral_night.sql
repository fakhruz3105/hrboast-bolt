-- First drop the trigger that depends on the function
DROP TRIGGER IF EXISTS validate_status_change ON staff;

-- Now we can safely drop the function
DROP FUNCTION IF EXISTS validate_staff_status_change;

-- Create improved function to validate status changes
CREATE OR REPLACE FUNCTION validate_staff_status_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Allow changing from resigned to permanent for admin user
  IF OLD.email = 'admin@example.com' THEN
    RETURN NEW;
  END IF;

  -- For other users, prevent changing from resigned
  IF OLD.status = 'resigned' AND NEW.status != 'resigned' THEN
    RAISE EXCEPTION 'Cannot change status from resigned to %', NEW.status;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for status validation
CREATE TRIGGER validate_status_change
  BEFORE UPDATE OF status ON staff
  FOR EACH ROW
  EXECUTE FUNCTION validate_staff_status_change();

-- Update admin user status to permanent
UPDATE staff 
SET status = 'permanent'
WHERE email = 'admin@example.com';