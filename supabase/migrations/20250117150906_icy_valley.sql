-- Create function to generate schema name from company ID
CREATE OR REPLACE FUNCTION generate_schema_name(company_id uuid)
RETURNS text AS $$
BEGIN
  RETURN 'company_' || replace(company_id::text, '-', '_');
END;
$$ LANGUAGE plpgsql;

-- Add schema_name column to companies table
ALTER TABLE companies
ADD COLUMN IF NOT EXISTS schema_name text UNIQUE;

-- Create function to get company schema
CREATE OR REPLACE FUNCTION get_company_schema(p_user_id uuid)
RETURNS text AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name from companies table
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;
  
  RETURN v_schema_name;
END;
$$ LANGUAGE plpgsql;

-- Create function to initialize company schema
CREATE OR REPLACE FUNCTION initialize_company_schema(p_company_id uuid)
RETURNS void AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Generate schema name
  v_schema_name := generate_schema_name(p_company_id);
  
  -- Update company record with schema name
  UPDATE companies
  SET schema_name = v_schema_name
  WHERE id = p_company_id;

  -- Create schema
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', v_schema_name);

  -- Create tables in new schema
  EXECUTE format('
    -- Staff table
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
    );

    -- Staff departments table
    CREATE TABLE IF NOT EXISTS %I.staff_departments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      department_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, department_id)
    );

    -- Staff levels junction table
    CREATE TABLE IF NOT EXISTS %I.staff_levels_junction (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      is_primary boolean DEFAULT false,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(staff_id, level_id)
    );

    -- Benefits table
    CREATE TABLE IF NOT EXISTS %I.benefits (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      name text NOT NULL,
      description text,
      amount numeric(10,2) NOT NULL,
      status boolean DEFAULT true,
      frequency text NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Benefit eligibility table
    CREATE TABLE IF NOT EXISTS %I.benefit_eligibility (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      benefit_id uuid REFERENCES %I.benefits(id) ON DELETE CASCADE,
      level_id uuid NOT NULL,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now(),
      UNIQUE(benefit_id, level_id)
    );

    -- Benefit claims table
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
    );

    -- Evaluation forms table
    CREATE TABLE IF NOT EXISTS %I.evaluation_forms (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type evaluation_type NOT NULL,
      questions jsonb NOT NULL DEFAULT ''[]'',
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );

    -- Evaluation responses table
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
    );

    -- Warning letters table
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
    );

    -- HR letters table
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
    );

    -- Memos table
    CREATE TABLE IF NOT EXISTS %I.memos (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      title text NOT NULL,
      type memo_type NOT NULL,
      content text NOT NULL,
      department_id uuid,
      staff_id uuid REFERENCES %I.staff(id) ON DELETE CASCADE,
      created_at timestamptz DEFAULT now(),
      updated_at timestamptz DEFAULT now()
    );',
    v_schema_name, -- staff
    v_schema_name, v_schema_name, -- staff_departments
    v_schema_name, v_schema_name, -- staff_levels_junction
    v_schema_name, -- benefits
    v_schema_name, v_schema_name, -- benefit_eligibility
    v_schema_name, v_schema_name, v_schema_name, -- benefit_claims
    v_schema_name, -- evaluation_forms
    v_schema_name, v_schema_name, v_schema_name, v_schema_name, -- evaluation_responses
    v_schema_name, v_schema_name, -- warning_letters
    v_schema_name, v_schema_name, -- hr_letters
    v_schema_name, v_schema_name -- memos
  );

  -- Grant usage on schema to authenticated users
  EXECUTE format('GRANT USAGE ON SCHEMA %I TO authenticated', v_schema_name);
  
  -- Grant access to all tables in schema
  EXECUTE format('GRANT ALL ON ALL TABLES IN SCHEMA %I TO authenticated', v_schema_name);
END;
$$ LANGUAGE plpgsql;

-- Create function to migrate data to company schema
CREATE OR REPLACE FUNCTION migrate_data_to_company_schema(p_company_id uuid)
RETURNS void AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Skip Muslimtravelbug
  IF EXISTS (
    SELECT 1 FROM companies 
    WHERE id = p_company_id 
    AND name = 'Muslimtravelbug Sdn Bhd'
  ) THEN
    RETURN;
  END IF;

  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    -- Initialize schema if it doesn't exist
    PERFORM initialize_company_schema(p_company_id);
    SELECT schema_name INTO v_schema_name
    FROM companies
    WHERE id = p_company_id;
  END IF;

  -- Migrate staff data
  EXECUTE format('
    INSERT INTO %I.staff (
      id, name, email, phone_number, join_date, status, is_active, role_id
    )
    SELECT 
      id, name, email, phone_number, join_date, status, is_active, role_id
    FROM staff
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate staff departments
  EXECUTE format('
    INSERT INTO %I.staff_departments (
      staff_id, department_id, is_primary
    )
    SELECT 
      sd.staff_id, sd.department_id, sd.is_primary
    FROM staff_departments sd
    JOIN staff s ON sd.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate staff levels
  EXECUTE format('
    INSERT INTO %I.staff_levels_junction (
      staff_id, level_id, is_primary
    )
    SELECT 
      slj.staff_id, slj.level_id, slj.is_primary
    FROM staff_levels_junction slj
    JOIN staff s ON slj.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefits
  EXECUTE format('
    INSERT INTO %I.benefits (
      id, name, description, amount, status, frequency
    )
    SELECT 
      id, name, description, amount, status, frequency
    FROM benefits
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefit eligibility
  EXECUTE format('
    INSERT INTO %I.benefit_eligibility (
      benefit_id, level_id
    )
    SELECT 
      be.benefit_id, be.level_id
    FROM benefit_eligibility be
    JOIN benefits b ON be.benefit_id = b.id
    WHERE b.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate benefit claims
  EXECUTE format('
    INSERT INTO %I.benefit_claims (
      benefit_id, staff_id, amount, status, claim_date, receipt_url, notes
    )
    SELECT 
      bc.benefit_id, bc.staff_id, bc.amount, bc.status, bc.claim_date,
      bc.receipt_url, bc.notes
    FROM benefit_claims bc
    JOIN staff s ON bc.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation forms
  EXECUTE format('
    INSERT INTO %I.evaluation_forms (
      id, title, type, questions
    )
    SELECT 
      ef.id, ef.title, ef.type, ef.questions
    FROM evaluation_forms ef
    WHERE company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation responses
  EXECUTE format('
    INSERT INTO %I.evaluation_responses (
      evaluation_id, staff_id, manager_id, self_ratings, self_comments,
      manager_ratings, manager_comments, percentage_score, status,
      submitted_at, completed_at
    )
    SELECT 
      er.evaluation_id, er.staff_id, er.manager_id, er.self_ratings,
      er.self_comments, er.manager_ratings, er.manager_comments,
      er.percentage_score, er.status, er.submitted_at, er.completed_at
    FROM evaluation_responses er
    JOIN staff s ON er.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate warning letters
  EXECUTE format('
    INSERT INTO %I.warning_letters (
      staff_id, warning_level, incident_date, description, improvement_plan,
      consequences, issued_date, show_cause_response, response_submitted_at
    )
    SELECT 
      wl.staff_id, wl.warning_level, wl.incident_date, wl.description,
      wl.improvement_plan, wl.consequences, wl.issued_date,
      wl.show_cause_response, wl.response_submitted_at
    FROM warning_letters wl
    JOIN staff s ON wl.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate HR letters
  EXECUTE format('
    INSERT INTO %I.hr_letters (
      staff_id, title, type, content, document_url, issued_date, status
    )
    SELECT 
      hl.staff_id, hl.title, hl.type, hl.content, hl.document_url,
      hl.issued_date, hl.status
    FROM hr_letters hl
    JOIN staff s ON hl.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );

  -- Migrate memos
  EXECUTE format('
    INSERT INTO %I.memos (
      title, type, content, department_id, staff_id
    )
    SELECT 
      m.title, m.type, m.content, m.department_id, m.staff_id
    FROM memos m
    JOIN staff s ON m.staff_id = s.id
    WHERE s.company_id = %L',
    v_schema_name, p_company_id
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to initialize new company
CREATE OR REPLACE FUNCTION initialize_new_company(
  p_name text,
  p_email text,
  p_phone text,
  p_address text
)
RETURNS uuid AS $$
DECLARE
  v_company_id uuid;
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

  -- Initialize schema for new company
  PERFORM initialize_company_schema(v_company_id);

  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company schema name
CREATE OR REPLACE FUNCTION get_company_schema_name(p_company_id uuid)
RETURNS text AS $$
BEGIN
  RETURN (
    SELECT schema_name 
    FROM companies 
    WHERE id = p_company_id
  );
END;
$$ LANGUAGE plpgsql;