-- Create function to migrate existing data to company schema
CREATE OR REPLACE FUNCTION migrate_company_data(
  p_company_id uuid
)
RETURNS void AS $$
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

  -- Migrate staff data
  EXECUTE format('
    INSERT INTO %I.staff (
      id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
    )
    SELECT 
      id, name, email, phone_number, join_date, status, is_active, role_id, created_at, updated_at
    FROM public.staff
    WHERE company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      email = EXCLUDED.email,
      phone_number = EXCLUDED.phone_number,
      join_date = EXCLUDED.join_date,
      status = EXCLUDED.status,
      is_active = EXCLUDED.is_active,
      role_id = EXCLUDED.role_id,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate staff departments
  EXECUTE format('
    INSERT INTO %I.staff_departments (
      id, staff_id, department_id, is_primary, created_at, updated_at
    )
    SELECT 
      sd.id, sd.staff_id, sd.department_id, sd.is_primary, sd.created_at, sd.updated_at
    FROM public.staff_departments sd
    JOIN public.staff s ON sd.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (staff_id, department_id) DO UPDATE SET
      is_primary = EXCLUDED.is_primary,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate staff levels
  EXECUTE format('
    INSERT INTO %I.staff_levels_junction (
      id, staff_id, level_id, is_primary, created_at, updated_at
    )
    SELECT 
      slj.id, slj.staff_id, slj.level_id, slj.is_primary, slj.created_at, slj.updated_at
    FROM public.staff_levels_junction slj
    JOIN public.staff s ON slj.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (staff_id, level_id) DO UPDATE SET
      is_primary = EXCLUDED.is_primary,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefits
  EXECUTE format('
    INSERT INTO %I.benefits (
      id, name, description, amount, status, frequency, created_at, updated_at
    )
    SELECT 
      id, name, description, amount, status, frequency, created_at, updated_at
    FROM public.benefits
    WHERE company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      description = EXCLUDED.description,
      amount = EXCLUDED.amount,
      status = EXCLUDED.status,
      frequency = EXCLUDED.frequency,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefit eligibility
  EXECUTE format('
    INSERT INTO %I.benefit_eligibility (
      id, benefit_id, level_id, created_at, updated_at
    )
    SELECT 
      be.id, be.benefit_id, be.level_id, be.created_at, be.updated_at
    FROM public.benefit_eligibility be
    JOIN public.benefits b ON be.benefit_id = b.id
    WHERE b.company_id = %L
    ON CONFLICT (benefit_id, level_id) DO UPDATE SET
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate benefit claims
  EXECUTE format('
    INSERT INTO %I.benefit_claims (
      id, benefit_id, staff_id, amount, status, claim_date, receipt_url, notes, created_at, updated_at
    )
    SELECT 
      bc.id, bc.benefit_id, bc.staff_id, bc.amount, bc.status, bc.claim_date, bc.receipt_url, bc.notes, bc.created_at, bc.updated_at
    FROM public.benefit_claims bc
    JOIN public.staff s ON bc.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      amount = EXCLUDED.amount,
      status = EXCLUDED.status,
      receipt_url = EXCLUDED.receipt_url,
      notes = EXCLUDED.notes,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation forms
  EXECUTE format('
    INSERT INTO %I.evaluation_forms (
      id, title, type, questions, created_at, updated_at
    )
    SELECT 
      ef.id, ef.title, ef.type, ef.questions, ef.created_at, ef.updated_at
    FROM public.evaluation_forms ef
    JOIN public.evaluation_responses er ON ef.id = er.evaluation_id
    JOIN public.staff s ON er.staff_id = s.id
    WHERE s.company_id = %L
    GROUP BY ef.id
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      type = EXCLUDED.type,
      questions = EXCLUDED.questions,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate evaluation responses
  EXECUTE format('
    INSERT INTO %I.evaluation_responses (
      id, evaluation_id, staff_id, manager_id, self_ratings, self_comments,
      manager_ratings, manager_comments, percentage_score, status,
      submitted_at, completed_at, created_at, updated_at
    )
    SELECT 
      er.id, er.evaluation_id, er.staff_id, er.manager_id, er.self_ratings,
      er.self_comments, er.manager_ratings, er.manager_comments, er.percentage_score,
      er.status, er.submitted_at, er.completed_at, er.created_at, er.updated_at
    FROM public.evaluation_responses er
    JOIN public.staff s ON er.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      self_ratings = EXCLUDED.self_ratings,
      self_comments = EXCLUDED.self_comments,
      manager_ratings = EXCLUDED.manager_ratings,
      manager_comments = EXCLUDED.manager_comments,
      percentage_score = EXCLUDED.percentage_score,
      status = EXCLUDED.status,
      submitted_at = EXCLUDED.submitted_at,
      completed_at = EXCLUDED.completed_at,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate warning letters
  EXECUTE format('
    INSERT INTO %I.warning_letters (
      id, staff_id, warning_level, incident_date, description, improvement_plan,
      consequences, issued_date, show_cause_response, response_submitted_at,
      created_at, updated_at
    )
    SELECT 
      wl.id, wl.staff_id, wl.warning_level, wl.incident_date, wl.description,
      wl.improvement_plan, wl.consequences, wl.issued_date, wl.show_cause_response,
      wl.response_submitted_at, wl.created_at, wl.updated_at
    FROM public.warning_letters wl
    JOIN public.staff s ON wl.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      description = EXCLUDED.description,
      improvement_plan = EXCLUDED.improvement_plan,
      consequences = EXCLUDED.consequences,
      show_cause_response = EXCLUDED.show_cause_response,
      response_submitted_at = EXCLUDED.response_submitted_at,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate HR letters
  EXECUTE format('
    INSERT INTO %I.hr_letters (
      id, staff_id, title, type, content, document_url, issued_date, status,
      created_at, updated_at
    )
    SELECT 
      hl.id, hl.staff_id, hl.title, hl.type, hl.content, hl.document_url,
      hl.issued_date, hl.status, hl.created_at, hl.updated_at
    FROM public.hr_letters hl
    JOIN public.staff s ON hl.staff_id = s.id
    WHERE s.company_id = %L
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      document_url = EXCLUDED.document_url,
      status = EXCLUDED.status,
      updated_at = now()',
    v_schema_name, p_company_id
  );

  -- Migrate memos
  EXECUTE format('
    INSERT INTO %I.memos (
      id, title, type, content, department_id, staff_id, created_at, updated_at
    )
    SELECT 
      m.id, m.title, m.type, m.content, m.department_id, m.staff_id,
      m.created_at, m.updated_at
    FROM public.memos m
    LEFT JOIN public.staff s ON m.staff_id = s.id
    WHERE s.company_id = %L OR m.department_id IN (
      SELECT DISTINCT department_id 
      FROM public.staff_departments sd
      JOIN public.staff s2 ON sd.staff_id = s2.id
      WHERE s2.company_id = %L
    )
    ON CONFLICT (id) DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      updated_at = now()',
    v_schema_name, p_company_id, p_company_id
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to verify company schema integrity
CREATE OR REPLACE FUNCTION verify_company_schema(
  p_company_id uuid
)
RETURNS TABLE (
  table_name text,
  record_count bigint,
  last_updated timestamptz
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

  RETURN QUERY EXECUTE format('
    SELECT 
      table_name::text,
      (SELECT count(*) FROM %I.' || quote_ident(table_name) || ') as record_count,
      (SELECT max(updated_at) FROM %I.' || quote_ident(table_name) || ') as last_updated
    FROM information_schema.tables
    WHERE table_schema = %L
    AND table_type = ''BASE TABLE''',
    v_schema_name, v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to cleanup orphaned company data
CREATE OR REPLACE FUNCTION cleanup_company_data(
  p_company_id uuid
)
RETURNS void AS $$
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

  -- Delete orphaned records
  EXECUTE format('
    -- Delete benefit claims without valid benefits
    DELETE FROM %I.benefit_claims bc
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefits b WHERE b.id = bc.benefit_id
    );

    -- Delete benefit eligibility without valid benefits
    DELETE FROM %I.benefit_eligibility be
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefits b WHERE b.id = be.benefit_id
    );

    -- Delete evaluation responses without valid forms
    DELETE FROM %I.evaluation_responses er
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.evaluation_forms ef WHERE ef.id = er.evaluation_id
    );

    -- Delete staff departments without valid staff
    DELETE FROM %I.staff_departments sd
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = sd.staff_id
    );

    -- Delete staff levels without valid staff
    DELETE FROM %I.staff_levels_junction sl
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = sl.staff_id
    );',
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;