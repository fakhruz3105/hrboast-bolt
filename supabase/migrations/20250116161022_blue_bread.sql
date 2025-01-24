-- Create tables in company schema
CREATE OR REPLACE FUNCTION create_company_schema(
  p_company_id uuid,
  p_schema_name text
)
RETURNS void AS $$
BEGIN
  -- Create new schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', p_schema_name);

  -- Create staff table
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

  -- Create staff departments table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.staff_departments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      department_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, department_id)
    )', p_schema_name, p_schema_name);

  -- Create staff levels junction table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.staff_levels_junction (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, level_id)
    )', p_schema_name, p_schema_name);

  -- Create benefits table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.benefits (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      description text,
      amount numeric(10,2) NOT NULL,
      status boolean DEFAULT true,
      frequency text NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name);

  -- Create benefit eligibility table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.benefit_eligibility (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      benefit_id uuid REFERENCES %I.benefits(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(benefit_id, level_id)
    )', p_schema_name, p_schema_name);

  -- Create benefit claims table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.benefit_claims (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      benefit_id uuid REFERENCES %I.benefits(id) ON DELETE CASCADE,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      amount numeric(10,2) NOT NULL,
      status text NOT NULL DEFAULT ''pending'',
      claim_date date NOT NULL DEFAULT CURRENT_DATE,
      receipt_url text,
      notes text,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name, p_schema_name, p_schema_name);

  -- Create evaluation forms table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.evaluation_forms (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type evaluation_type NOT NULL,
      questions jsonb NOT NULL DEFAULT ''[]'',
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name);

  -- Create evaluation responses table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.evaluation_responses (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      evaluation_id uuid REFERENCES %I.evaluation_forms(id) ON DELETE CASCADE,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      manager_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      self_ratings jsonb NOT NULL DEFAULT ''{}''::jsonb,
      self_comments jsonb NOT NULL DEFAULT ''{}''::jsonb,
      manager_ratings jsonb NOT NULL DEFAULT ''{}''::jsonb,
      manager_comments jsonb NOT NULL DEFAULT ''{}''::jsonb,
      percentage_score numeric(5,2),
      status evaluation_status NOT NULL DEFAULT ''pending'',
      submitted_at timestamptz,
      completed_at timestamptz,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name, p_schema_name, p_schema_name, p_schema_name);

  -- Create warning letters table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.warning_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      warning_level warning_level NOT NULL,
      incident_date date NOT NULL,
      description text NOT NULL,
      improvement_plan text NOT NULL,
      consequences text NOT NULL,
      issued_date date NOT NULL,
      show_cause_response text,
      response_submitted_at timestamptz,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name, p_schema_name);

  -- Create HR letters table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.hr_letters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      title text NOT NULL,
      type letter_type NOT NULL,
      content jsonb NOT NULL DEFAULT ''{}''::jsonb,
      document_url text,
      issued_date timestamptz NOT NULL DEFAULT now(),
      status letter_status NOT NULL DEFAULT ''submitted'',
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name, p_schema_name);

  -- Create memos table
  EXECUTE format('
    CREATE TABLE IF NOT EXISTS %I.memos (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type memo_type NOT NULL,
      content text NOT NULL,
      department_id uuid,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    )', p_schema_name, p_schema_name);

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', p_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', p_schema_name);
END;
$$ LANGUAGE plpgsql;