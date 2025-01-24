-- Create function to update staff password
CREATE OR REPLACE FUNCTION update_staff_password(
  p_email text,
  p_password text
)
RETURNS void AS $$
BEGIN
  -- Verify staff exists and get their company_id
  IF NOT EXISTS (
    SELECT 1 FROM staff WHERE email = p_email
  ) THEN
    RAISE EXCEPTION 'Staff member not found';
  END IF;

  -- Update the staff password
  -- In a real application, you would use proper password hashing
  -- For demo purposes, we'll store the password directly
  UPDATE staff
  SET 
    password_hash = p_password,
    updated_at = now()
  WHERE email = p_email;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;