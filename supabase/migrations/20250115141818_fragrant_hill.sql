-- Add password_hash column to companies table if it doesn't exist
ALTER TABLE companies 
ADD COLUMN IF NOT EXISTS password_hash text;

-- Create function to update company admin password
CREATE OR REPLACE FUNCTION update_company_admin_password(
  p_company_id uuid,
  p_password text
)
RETURNS void AS $$
BEGIN
  -- Update company password
  UPDATE companies
  SET 
    password_hash = p_password,
    updated_at = now()
  WHERE id = p_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;