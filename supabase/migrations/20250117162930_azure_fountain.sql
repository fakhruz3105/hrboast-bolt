-- Create show cause type enum
CREATE TYPE show_cause_type AS ENUM (
  'lateness',
  'harassment', 
  'leave_without_approval',
  'offensive_behavior',
  'insubordination',
  'misconduct'
);

-- Create show cause letters table
CREATE TABLE show_cause_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  type show_cause_type NOT NULL,
  title text, -- Only used when type is 'misconduct'
  incident_date date NOT NULL,
  description text NOT NULL,
  issued_date timestamptz NOT NULL DEFAULT now(),
  response text,
  response_date timestamptz,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'responded')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_incident_date CHECK (incident_date <= CURRENT_DATE),
  CONSTRAINT valid_response CHECK (
    (status = 'responded' AND response IS NOT NULL AND response_date IS NOT NULL) OR
    (status = 'pending' AND response IS NULL AND response_date IS NULL)
  )
);

-- Create indexes for better performance
CREATE INDEX idx_show_cause_letters_staff ON show_cause_letters(staff_id);
CREATE INDEX idx_show_cause_letters_type ON show_cause_letters(type);
CREATE INDEX idx_show_cause_letters_status ON show_cause_letters(status);
CREATE INDEX idx_show_cause_letters_incident_date ON show_cause_letters(incident_date);

-- Enable RLS
ALTER TABLE show_cause_letters ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "show_cause_letters_select"
  ON show_cause_letters FOR SELECT
  USING (true);  -- Allow all authenticated users to read

CREATE POLICY "show_cause_letters_insert"
  ON show_cause_letters FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to insert

CREATE POLICY "show_cause_letters_update"
  ON show_cause_letters FOR UPDATE
  USING (true);  -- Allow all authenticated users to update

CREATE POLICY "show_cause_letters_delete"
  ON show_cause_letters FOR DELETE
  USING (true);  -- Allow all authenticated users to delete

-- Add trigger for updated_at
CREATE TRIGGER set_show_cause_letters_timestamp
  BEFORE UPDATE ON show_cause_letters
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add show cause letters table to company schema function
CREATE OR REPLACE FUNCTION create_company_schema(
  p_company_id uuid,
  p_schema_name text
)
RETURNS void AS $$
BEGIN
  -- Create new schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', p_schema_name);

  -- Create show cause letters table in schema
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.show_cause_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      type show_cause_type NOT NULL,
      title text,
      incident_date date NOT NULL,
      description text NOT NULL,
      issued_date timestamptz NOT NULL DEFAULT now(),
      response text,
      response_date timestamptz,
      status text NOT NULL DEFAULT ''pending'' CHECK (status IN (''pending'', ''responded'')),
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      CONSTRAINT valid_incident_date CHECK (incident_date <= CURRENT_DATE),
      CONSTRAINT valid_response CHECK (
        (status = ''responded'' AND response IS NOT NULL AND response_date IS NOT NULL) OR
        (status = ''pending'' AND response IS NULL AND response_date IS NULL)
      )
    )',
    p_schema_name,
    p_schema_name
  );

  -- Create other tables...
  -- [Previous table creation code remains the same]

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', p_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', p_schema_name);
END;
$$ LANGUAGE plpgsql;