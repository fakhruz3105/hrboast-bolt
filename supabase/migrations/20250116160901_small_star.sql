-- First create schema for Muslimtravelbug
DO $$
DECLARE
  v_company_id uuid;
  v_schema_name text;
BEGIN
  -- Get Muslimtravelbug company ID
  SELECT id INTO v_company_id 
  FROM companies 
  WHERE name = 'Muslimtravelbug Sdn Bhd';

  IF v_company_id IS NOT NULL THEN
    -- Generate schema name
    v_schema_name := 'company_' || replace(v_company_id::text, '-', '_');

    -- Create schema
    PERFORM create_company_schema(v_company_id, v_schema_name);

    -- Update company record with schema name
    UPDATE companies
    SET schema_name = v_schema_name
    WHERE id = v_company_id;

    -- Migrate existing data to new schema
    EXECUTE format('
      -- Copy staff data
      INSERT INTO %I.staff (
        id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
      )
      SELECT 
        id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
      FROM public.staff
      WHERE company_id = %L;
      
      -- Copy other tables as needed...
    ', v_schema_name, v_company_id);
  END IF;
END $$;

-- Create function to handle company data access
CREATE OR REPLACE FUNCTION get_company_data(
  p_table_name text,
  p_user_id uuid
)
RETURNS SETOF json AS $$
DECLARE
  v_schema_name text;
  v_sql text;
BEGIN
  -- Get schema name for user's company
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Build and execute query
  v_sql := format('SELECT row_to_json(t) FROM %I.%I t', v_schema_name, p_table_name);
  RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

-- Create function to insert company data
CREATE OR REPLACE FUNCTION insert_company_data(
  p_table_name text,
  p_user_id uuid,
  p_data json
)
RETURNS json AS $$
DECLARE
  v_schema_name text;
  v_sql text;
  v_result json;
BEGIN
  -- Get schema name for user's company
  SELECT c.schema_name INTO v_schema_name
  FROM companies c
  JOIN staff s ON s.company_id = c.id
  WHERE s.id = p_user_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Build and execute insert query
  v_sql := format('
    INSERT INTO %I.%I 
    SELECT * FROM json_populate_record(null::%I.%I, %L)
    RETURNING row_to_json(%I.*)',
    v_schema_name, p_table_name,
    v_schema_name, p_table_name,
    p_data,
    p_table_name
  );
  
  EXECUTE v_sql INTO v_result;
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;