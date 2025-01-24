-- Add is_active column to staff table
ALTER TABLE staff
ADD COLUMN is_active boolean DEFAULT false;

-- Set existing admin and staff users to active
UPDATE staff 
SET is_active = true 
WHERE email IN ('admin@example.com', 'staff@example.com');

-- Create index for better performance
CREATE INDEX idx_staff_is_active ON staff(is_active);

-- Add function to toggle user active status
CREATE OR REPLACE FUNCTION toggle_user_active_status(p_staff_id uuid)
RETURNS void AS $$
BEGIN
  UPDATE staff
  SET is_active = NOT is_active
  WHERE id = p_staff_id;
END;
$$ LANGUAGE plpgsql;