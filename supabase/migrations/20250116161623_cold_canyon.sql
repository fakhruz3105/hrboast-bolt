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
RETURNS TABLE (
  id uuid,
  name text,
  email text,
  phone_number text,
  join_date date,
  status text,
  is_active boolean,
  role_id uuid,
  departments jsonb,
  levels jsonb
) AS $$
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

  -- Return staff details
  RETURN QUERY EXECUTE format('
    SELECT 
      s.id,
      s.name,
      s.email,
      s.phone_number,
      s.join_date,
      s.status::text,
      s.is_active,
      s.role_id,
      COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
          ''department_id'', sd.department_id,
          ''is_primary'', sd.is_primary
        )) FILTER (WHERE sd.id IS NOT NULL),
        ''[]''::jsonb
      ) as departments,
      COALESCE(
        jsonb_agg(DISTINCT jsonb_build_object(
          ''level_id'', sl.level_id,
          ''is_primary'', sl.is_primary
        )) FILTER (WHERE sl.id IS NOT NULL),
        ''[]''::jsonb
      ) as levels
    FROM %I.staff s
    LEFT JOIN %I.staff_departments sd ON s.id = sd.staff_id
    LEFT JOIN %I.staff_levels_junction sl ON s.id = sl.staff_id
    WHERE s.id = %L
    GROUP BY s.id',
    v_schema_name, v_schema_name, v_schema_name, p_staff_id
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company evaluations
CREATE OR REPLACE FUNCTION get_company_evaluations(
  p_company_id uuid
)
RETURNS TABLE (
  id uuid,
  title text,
  type text,
  questions jsonb,
  created_at timestamptz,
  updated_at timestamptz,
  assigned_staff uuid[]
) AS $$
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
    SELECT 
      ef.id,
      ef.title,
      ef.type::text,
      ef.questions,
      ef.created_at,
      ef.updated_at,
      array_agg(DISTINCT er.staff_id) FILTER (WHERE er.staff_id IS NOT NULL) as assigned_staff
    FROM %I.evaluation_forms ef
    LEFT JOIN %I.evaluation_responses er ON ef.id = er.evaluation_id
    GROUP BY ef.id
    ORDER BY ef.created_at DESC',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company benefits
CREATE OR REPLACE FUNCTION get_company_benefits(
  p_company_id uuid
)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  created_at timestamptz,
  updated_at timestamptz,
  eligible_levels uuid[]
) AS $$
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
    SELECT 
      b.id,
      b.name,
      b.description,
      b.amount,
      b.status,
      b.frequency,
      b.created_at,
      b.updated_at,
      array_agg(DISTINCT be.level_id) FILTER (WHERE be.level_id IS NOT NULL) as eligible_levels
    FROM %I.benefits b
    LEFT JOIN %I.benefit_eligibility be ON b.id = be.benefit_id
    GROUP BY b.id
    ORDER BY b.created_at DESC',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to get company warning letters
CREATE OR REPLACE FUNCTION get_company_warning_letters(
  p_company_id uuid
)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  warning_level text,
  incident_date date,
  description text,
  improvement_plan text,
  consequences text,
  issued_date date,
  show_cause_response text,
  response_submitted_at timestamptz,
  staff_name text
) AS $$
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
    SELECT 
      wl.id,
      wl.staff_id,
      wl.warning_level::text,
      wl.incident_date,
      wl.description,
      wl.improvement_plan,
      wl.consequences,
      wl.issued_date,
      wl.show_cause_response,
      wl.response_submitted_at,
      s.name as staff_name
    FROM %I.warning_letters wl
    JOIN %I.staff s ON wl.staff_id = s.id
    ORDER BY wl.issued_date DESC',
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;