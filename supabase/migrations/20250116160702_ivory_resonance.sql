-- Create function to create a new schema for a company
CREATE OR REPLACE FUNCTION create_company_schema(
  p_company_id uuid,
  p_schema_name text
)
RETURNS void AS $$
BEGIN
  -- Create new schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', p_schema_name);

  -- Create company-specific tables in the new schema
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.staff (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      email text NOT NULL UNIQUE,
      phone_number text NOT NULL,
      join_date date NOT NULL DEFAULT CURRENT_DATE,
      status staff_status NOT NULL DEFAULT ''probation'',
      is_active boolean DEFAULT true,
      role_id uuid NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name);

  -- Create other company-specific tables...
  -- [Add more table creation statements as needed]

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', p_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', p_schema_name);
END;
$$ LANGUAGE plpgsql;

-- Create function to initialize a new company
CREATE OR REPLACE FUNCTION initialize_new_company(
  p_name text,
  p_email text,
  p_phone text,
  p_address text
)
RETURNS uuid AS $$
DECLARE
  v_company_id uuid;
  v_schema_name text;
BEGIN
  -- Create company record
  INSERT INTO companies (
    name,
    email,
    phone,
    address,
    trial_ends_at,
    is_active
  ) VALUES (
    p_name,
    p_email,
    p_phone,
    p_address,
    now() + interval '14 days',
    true
  ) RETURNING id INTO v_company_id;

  -- Generate schema name from company ID
  v_schema_name := 'company_' || replace(v_company_id::text, '-', '_');

  -- Create schema for the company
  PERFORM create_company_schema(v_company_id, v_schema_name);

  -- Store schema name in companies table
  UPDATE companies
  SET schema_name = v_schema_name
  WHERE id = v_company_id;

  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;

-- Add schema_name column to companies table
ALTER TABLE companies 
ADD COLUMN IF NOT EXISTS schema_name text UNIQUE;

-- Create index for schema lookup
CREATE INDEX IF NOT EXISTS idx_companies_schema_name 
ON companies(schema_name);

-- Create function to get company schema name
CREATE OR REPLACE FUNCTION get_company_schema(p_user_id uuid)
RETURNS text AS $$
DECLARE
  v_schema_name text;
BEGIN
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;
  
  RETURN v_schema_name;
END;
$$ LANGUAGE plpgsql;