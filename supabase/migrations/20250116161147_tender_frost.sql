-- First drop existing functions to avoid conflicts
DROP FUNCTION IF EXISTS get_company_staff_details(uuid, uuid);
DROP FUNCTION IF EXISTS get_company_evaluations(uuid);
DROP FUNCTION IF EXISTS get_company_benefits(uuid);
DROP FUNCTION IF EXISTS get_company_warning_letters(uuid);

-- Create function to get staff details from company schema
CREATE OR REPLACE FUNCTION get_company_staff_details(
  p_company_id uuid,
  p_staff_id uuid
)
RETURNS json AS $$
DECLARE
  v_schema_name text;
  v_result json;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Get staff details
  EXECUTE format('
    SELECT row_to_json(t) FROM (
      SELECT 
        s.*,
        array_agg(DISTINCT jsonb_build_object(
          ''department_id'', sd.department_id,
          ''is_primary'', sd.is_primary
        )) as departments,
        array_agg(DISTINCT jsonb_build_object(
          ''level_id'', sl.level_id,
          ''is_primary'', sl.is_primary
        )) as levels
      FROM %I.staff s
      LEFT JOIN %I.staff_departments sd ON s.id = sd.staff_id
      LEFT JOIN %I.staff_levels_junction sl ON s.id = sl.staff_id
      WHERE s.id = %L
      GROUP BY s.id
    ) t',
    v_schema_name, v_schema_name, v_schema_name, p_staff_id
  ) INTO v_result;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company evaluations
CREATE OR REPLACE FUNCTION get_company_evaluations(
  p_company_id uuid
)
RETURNS SETOF json AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return evaluations
  RETURN QUERY EXECUTE format('
    SELECT row_to_json(t) FROM (
      SELECT 
        ef.*,
        array_agg(DISTINCT er.staff_id) as assigned_staff
      FROM %I.evaluation_forms ef
      LEFT JOIN %I.evaluation_responses er ON ef.id = er.evaluation_id
      GROUP BY ef.id
      ORDER BY ef.created_at DESC
    ) t',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company benefits
CREATE OR REPLACE FUNCTION get_company_benefits(
  p_company_id uuid
)
RETURNS SETOF json AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return benefits
  RETURN QUERY EXECUTE format('
    SELECT row_to_json(t) FROM (
      SELECT 
        b.*,
        array_agg(DISTINCT be.level_id) as eligible_levels
      FROM %I.benefits b
      LEFT JOIN %I.benefit_eligibility be ON b.id = be.benefit_id
      GROUP BY b.id
      ORDER BY b.created_at DESC
    ) t',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company warning letters
CREATE OR REPLACE FUNCTION get_company_warning_letters(
  p_company_id uuid
)
RETURNS SETOF json AS $$
DECLARE
  v_schema_name text;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Return warning letters
  RETURN QUERY EXECUTE format('
    SELECT row_to_json(t) FROM (
      SELECT 
        wl.*,
        s.name as staff_name
      FROM %I.warning_letters wl
      JOIN %I.staff s ON wl.staff_id = s.id
      ORDER BY wl.issued_date DESC
    ) t',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;