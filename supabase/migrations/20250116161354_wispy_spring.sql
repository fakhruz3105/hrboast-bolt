-- Create function to validate staff data
CREATE OR REPLACE FUNCTION validate_staff_data(
  p_company_id uuid
)
RETURNS TABLE (
  staff_id uuid,
  validation_type text,
  validation_message text
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
    -- Check for staff without primary department
    SELECT 
      s.id,
      ''missing_primary_department''::text,
      ''Staff member has no primary department''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff_departments sd 
      WHERE sd.staff_id = s.id AND sd.is_primary = true
    )
    
    UNION ALL
    
    -- Check for staff without primary level
    SELECT 
      s.id,
      ''missing_primary_level''::text,
      ''Staff member has no primary level''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff_levels_junction sl 
      WHERE sl.staff_id = s.id AND sl.is_primary = true
    )
    
    UNION ALL
    
    -- Check for staff with multiple primary departments
    SELECT 
      s.id,
      ''multiple_primary_departments''::text,
      ''Staff member has multiple primary departments''::text
    FROM %I.staff s
    JOIN %I.staff_departments sd ON s.id = sd.staff_id
    WHERE sd.is_primary = true
    GROUP BY s.id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    -- Check for staff with multiple primary levels
    SELECT 
      s.id,
      ''multiple_primary_levels''::text,
      ''Staff member has multiple primary levels''::text
    FROM %I.staff s
    JOIN %I.staff_levels_junction sl ON s.id = sl.staff_id
    WHERE sl.is_primary = true
    GROUP BY s.id
    HAVING COUNT(*) > 1
    
    UNION ALL
    
    -- Check for staff with invalid role_id
    SELECT 
      s.id,
      ''invalid_role''::text,
      ''Staff member has invalid role_id''::text
    FROM %I.staff s
    WHERE NOT EXISTS (
      SELECT 1 FROM role_mappings rm WHERE rm.id = s.role_id
    )',
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name, v_schema_name,
    v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to validate benefit data
CREATE OR REPLACE FUNCTION validate_benefit_data(
  p_company_id uuid
)
RETURNS TABLE (
  benefit_id uuid,
  validation_type text,
  validation_message text
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
    -- Check for benefits without any eligible levels
    SELECT 
      b.id,
      ''no_eligible_levels''::text,
      ''Benefit has no eligible levels assigned''::text
    FROM %I.benefits b
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.benefit_eligibility be 
      WHERE be.benefit_id = b.id
    )
    
    UNION ALL
    
    -- Check for benefits with invalid amounts
    SELECT 
      b.id,
      ''invalid_amount''::text,
      ''Benefit amount must be greater than 0''::text
    FROM %I.benefits b
    WHERE b.amount <= 0
    
    UNION ALL
    
    -- Check for benefits with empty frequency
    SELECT 
      b.id,
      ''missing_frequency''::text,
      ''Benefit frequency is required''::text
    FROM %I.benefits b
    WHERE b.frequency IS NULL OR b.frequency = ''''
    
    UNION ALL
    
    -- Check for orphaned benefit claims
    SELECT 
      bc.benefit_id,
      ''orphaned_claim''::text,
      ''Benefit claim exists for inactive benefit''::text
    FROM %I.benefit_claims bc
    JOIN %I.benefits b ON bc.benefit_id = b.id
    WHERE b.status = false',
    v_schema_name, v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to validate evaluation data
CREATE OR REPLACE FUNCTION validate_evaluation_data(
  p_company_id uuid
)
RETURNS TABLE (
  evaluation_id uuid,
  validation_type text,
  validation_message text
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
    -- Check for evaluations without questions
    SELECT 
      ef.id,
      ''no_questions''::text,
      ''Evaluation form has no questions''::text
    FROM %I.evaluation_forms ef
    WHERE ef.questions IS NULL OR ef.questions::text = ''[]''
    
    UNION ALL
    
    -- Check for evaluations with invalid question structure
    SELECT 
      ef.id,
      ''invalid_questions''::text,
      ''Evaluation questions must have id, category, and question fields''::text
    FROM %I.evaluation_forms ef,
    jsonb_array_elements(ef.questions) q
    WHERE NOT (
      q ? ''id'' AND 
      q ? ''category'' AND 
      q ? ''question''
    )
    
    UNION ALL
    
    -- Check for completed evaluations without scores
    SELECT 
      er.evaluation_id,
      ''missing_score''::text,
      ''Completed evaluation has no percentage score''::text
    FROM %I.evaluation_responses er
    WHERE er.status = ''completed''
    AND er.percentage_score IS NULL
    
    UNION ALL
    
    -- Check for evaluations with invalid manager assignments
    SELECT 
      er.evaluation_id,
      ''invalid_manager''::text,
      ''Evaluation assigned to invalid manager''::text
    FROM %I.evaluation_responses er
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = er.manager_id
    )',
    v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to validate warning letter data
CREATE OR REPLACE FUNCTION validate_warning_letter_data(
  p_company_id uuid
)
RETURNS TABLE (
  letter_id uuid,
  validation_type text,
  validation_message text
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
    -- Check for warning letters with future incident dates
    SELECT 
      wl.id,
      ''future_incident_date''::text,
      ''Incident date cannot be in the future''::text
    FROM %I.warning_letters wl
    WHERE wl.incident_date > CURRENT_DATE
    
    UNION ALL
    
    -- Check for warning letters with issue date before incident date
    SELECT 
      wl.id,
      ''invalid_issue_date''::text,
      ''Issue date must be after incident date''::text
    FROM %I.warning_letters wl
    WHERE wl.issued_date < wl.incident_date
    
    UNION ALL
    
    -- Check for warning letters with empty required fields
    SELECT 
      wl.id,
      ''missing_required_fields''::text,
      ''Warning letter has empty required fields''::text
    FROM %I.warning_letters wl
    WHERE wl.description = '''' 
    OR wl.improvement_plan = '''' 
    OR wl.consequences = ''''
    
    UNION ALL
    
    -- Check for warning letters with invalid staff assignments
    SELECT 
      wl.id,
      ''invalid_staff''::text,
      ''Warning letter assigned to invalid staff member''::text
    FROM %I.warning_letters wl
    WHERE NOT EXISTS (
      SELECT 1 FROM %I.staff s WHERE s.id = wl.staff_id
    )',
    v_schema_name,
    v_schema_name,
    v_schema_name,
    v_schema_name, v_schema_name
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to run all validations
CREATE OR REPLACE FUNCTION validate_company_data(
  p_company_id uuid
)
RETURNS TABLE (
  entity_id uuid,
  entity_type text,
  validation_type text,
  validation_message text
) AS $$
BEGIN
  -- Staff validations
  RETURN QUERY
  SELECT 
    staff_id as entity_id,
    'staff'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_staff_data(p_company_id);

  -- Benefit validations
  RETURN QUERY
  SELECT 
    benefit_id as entity_id,
    'benefit'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_benefit_data(p_company_id);

  -- Evaluation validations
  RETURN QUERY
  SELECT 
    evaluation_id as entity_id,
    'evaluation'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_evaluation_data(p_company_id);

  -- Warning letter validations
  RETURN QUERY
  SELECT 
    letter_id as entity_id,
    'warning_letter'::text as entity_type,
    validation_type,
    validation_message
  FROM validate_warning_letter_data(p_company_id);
END;
$$ LANGUAGE plpgsql;