-- Create companies table if it doesn't exist
CREATE TABLE IF NOT EXISTS companies (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  phone text,
  address text,
  subscription_status text NOT NULL DEFAULT 'trial',
  trial_ends_at timestamptz,
  is_active boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- Create simplified RLS policies
CREATE POLICY "companies_view"
  ON companies FOR SELECT
  USING (true);

CREATE POLICY "companies_insert"
  ON companies FOR INSERT
  WITH CHECK (true);

CREATE POLICY "companies_update"
  ON companies FOR UPDATE
  USING (true);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_companies_status 
ON companies(subscription_status, is_active);

-- Add trigger for updated_at
CREATE TRIGGER set_companies_timestamp
  BEFORE UPDATE ON companies
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();