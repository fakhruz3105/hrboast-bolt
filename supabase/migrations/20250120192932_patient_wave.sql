-- Add new columns to companies table
ALTER TABLE companies
ADD COLUMN IF NOT EXISTS ssm text,
ADD COLUMN IF NOT EXISTS logo_url text;

-- Update Muslimtravelbug company details
UPDATE companies 
SET 
  name = 'Muslimtravelbug Sdn Bhd',
  ssm = '1186376T',
  address = '28-3 Jalan Equine 1D Taman Equine 43300 Seri Kembangan Selangor',
  phone = '03 95441442',
  logo_url = 'https://muslimtravelbug.com/wp-content/uploads/2023/12/mtb-logo.png'
WHERE name = 'Muslimtravelbug Sdn Bhd';

-- Create function to update company details
CREATE OR REPLACE FUNCTION update_company_details(
  p_company_id uuid,
  p_name text,
  p_ssm text,
  p_address text,
  p_phone text,
  p_logo_url text
)
RETURNS void AS $$
BEGIN
  UPDATE companies
  SET 
    name = p_name,
    ssm = p_ssm,
    address = p_address,
    phone = p_phone,
    logo_url = p_logo_url,
    updated_at = now()
  WHERE id = p_company_id;
END;
$$ LANGUAGE plpgsql;