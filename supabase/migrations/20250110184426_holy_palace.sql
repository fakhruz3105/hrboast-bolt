-- Insert Muslimtravelbug Sdn Bhd company
INSERT INTO companies (
  name,
  email,
  phone,
  address,
  subscription_status,
  trial_ends_at,
  is_active
) VALUES (
  'Muslimtravelbug Sdn Bhd',
  'admin@muslimtravelbug.com',
  '+60123456789',
  'Kuala Lumpur, Malaysia',
  'active',
  NULL,
  true
)
ON CONFLICT (email) DO NOTHING;

-- Update admin@example.com and staff@example.com to be part of Muslimtravelbug
UPDATE staff
SET company_id = (SELECT id FROM companies WHERE name = 'Muslimtravelbug Sdn Bhd')
WHERE email IN ('admin@example.com', 'staff@example.com');