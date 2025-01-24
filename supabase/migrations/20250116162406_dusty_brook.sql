-- Create function to cleanup company data
CREATE OR REPLACE FUNCTION cleanup_company_data(
  p_company_id uuid,
  p_cleanup_type text
)
RETURNS TABLE (
  cleanup_type text,
  items_removed integer,
  details text
) AS $$
DECLARE
  v_count integer;
BEGIN
  CASE p_cleanup_type
    -- Clean up inactive staff
    WHEN 'inactive_staff' THEN
      WITH deleted AS (
        DELETE FROM staff
        WHERE company_id = p_company_id
        AND is_active = false
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'inactive_staff'::text,
        v_count,
        'Removed ' || v_count || ' inactive staff members'::text;

    -- Clean up expired benefits
    WHEN 'expired_benefits' THEN
      WITH deleted AS (
        DELETE FROM benefits
        WHERE company_id = p_company_id
        AND status = false
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'expired_benefits'::text,
        v_count,
        'Removed ' || v_count || ' expired benefits'::text;

    -- Clean up old evaluations
    WHEN 'old_evaluations' THEN
      WITH deleted AS (
        DELETE FROM evaluation_responses er
        USING staff s
        WHERE s.company_id = p_company_id
        AND er.staff_id = s.id
        AND er.status = 'completed'
        AND er.completed_at < now() - interval '1 year'
        RETURNING er.id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_evaluations'::text,
        v_count,
        'Removed ' || v_count || ' evaluations older than 1 year'::text;

    -- Clean up old warning letters
    WHEN 'old_warnings' THEN
      WITH deleted AS (
        DELETE FROM warning_letters wl
        USING staff s
        WHERE s.company_id = p_company_id
        AND wl.staff_id = s.id
        AND wl.issued_date < now() - interval '2 years'
        RETURNING wl.id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_warnings'::text,
        v_count,
        'Removed ' || v_count || ' warning letters older than 2 years'::text;

    -- Clean up old memos
    WHEN 'old_memos' THEN
      WITH deleted AS (
        DELETE FROM memos m
        WHERE m.staff_id IN (
          SELECT id FROM staff WHERE company_id = p_company_id
        )
        AND m.created_at < now() - interval '1 year'
        RETURNING id
      )
      SELECT count(*) INTO v_count FROM deleted;
      
      RETURN QUERY SELECT 
        'old_memos'::text,
        v_count,
        'Removed ' || v_count || ' memos older than 1 year'::text;

    -- Clean up all data
    WHEN 'all' THEN
      -- Recursively call for each type
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'inactive_staff');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'expired_benefits');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_evaluations');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_warnings');
      RETURN QUERY SELECT * FROM cleanup_company_data(p_company_id, 'old_memos');

    ELSE
      RAISE EXCEPTION 'Invalid cleanup type: %', p_cleanup_type;
  END CASE;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company data statistics
CREATE OR REPLACE FUNCTION get_company_statistics(
  p_company_id uuid
)
RETURNS TABLE (
  category text,
  total_count bigint,
  active_count bigint,
  inactive_count bigint,
  last_updated timestamptz
) AS $$
BEGIN
  RETURN QUERY
  
  -- Staff statistics
  SELECT 
    'staff'::text as category,
    count(*) as total_count,
    count(*) FILTER (WHERE is_active = true) as active_count,
    count(*) FILTER (WHERE is_active = false) as inactive_count,
    max(updated_at) as last_updated
  FROM staff
  WHERE company_id = p_company_id
  
  UNION ALL
  
  -- Benefits statistics
  SELECT 
    'benefits'::text,
    count(*),
    count(*) FILTER (WHERE status = true),
    count(*) FILTER (WHERE status = false),
    max(updated_at)
  FROM benefits
  WHERE company_id = p_company_id
  
  UNION ALL
  
  -- Evaluations statistics
  SELECT 
    'evaluations'::text,
    count(*),
    count(*) FILTER (WHERE er.status = 'completed'),
    count(*) FILTER (WHERE er.status = 'pending'),
    max(er.updated_at)
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  WHERE s.company_id = p_company_id
  
  UNION ALL
  
  -- Warning letters statistics
  SELECT 
    'warning_letters'::text,
    count(*),
    count(*) FILTER (WHERE wl.show_cause_response IS NOT NULL),
    count(*) FILTER (WHERE wl.show_cause_response IS NULL),
    max(wl.updated_at)
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  WHERE s.company_id = p_company_id
  
  UNION ALL
  
  -- Memos statistics
  SELECT 
    'memos'::text,
    count(*),
    count(*),
    0,
    max(m.updated_at)
  FROM memos m
  WHERE m.staff_id IN (SELECT id FROM staff WHERE company_id = p_company_id)
  OR m.department_id IN (
    SELECT DISTINCT department_id 
    FROM staff_departments sd
    JOIN staff s ON sd.staff_id = s.id
    WHERE s.company_id = p_company_id
  );
END;
$$ LANGUAGE plpgsql;

-- Create function to validate company data integrity
CREATE OR REPLACE FUNCTION validate_company_integrity(
  p_company_id uuid
)
RETURNS TABLE (
  issue_type text,
  issue_count integer,
  details text
) AS $$
BEGIN
  RETURN QUERY
  
  -- Check for staff without departments
  SELECT 
    'staff_without_department'::text,
    count(*)::integer,
    'Staff members without any department assignment'::text
  FROM staff s
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM staff_departments sd WHERE sd.staff_id = s.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for staff without levels
  SELECT 
    'staff_without_level'::text,
    count(*)::integer,
    'Staff members without any level assignment'::text
  FROM staff s
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM staff_levels_junction sl WHERE sl.staff_id = s.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for benefits without eligibility
  SELECT 
    'benefits_without_eligibility'::text,
    count(*)::integer,
    'Benefits without any level eligibility'::text
  FROM benefits b
  WHERE b.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM benefit_eligibility be WHERE be.benefit_id = b.id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for orphaned evaluation responses
  SELECT 
    'orphaned_evaluations'::text,
    count(*)::integer,
    'Evaluation responses without valid evaluation forms'::text
  FROM evaluation_responses er
  JOIN staff s ON er.staff_id = s.id
  WHERE s.company_id = p_company_id
  AND NOT EXISTS (
    SELECT 1 FROM evaluation_forms ef WHERE ef.id = er.evaluation_id
  )
  HAVING count(*) > 0
  
  UNION ALL
  
  -- Check for orphaned warning letters
  SELECT 
    'orphaned_warnings'::text,
    count(*)::integer,
    'Warning letters for inactive staff'::text
  FROM warning_letters wl
  JOIN staff s ON wl.staff_id = s.id
  WHERE s.company_id = p_company_id
  AND s.is_active = false
  HAVING count(*) > 0;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company data summary
CREATE OR REPLACE FUNCTION get_company_data_summary(
  p_company_id uuid
)
RETURNS jsonb AS $$
DECLARE
  v_summary jsonb;
BEGIN
  SELECT jsonb_build_object(
    'company_info', (
      SELECT jsonb_build_object(
        'name', c.name,
        'email', c.email,
        'subscription_status', c.subscription_status,
        'is_active', c.is_active,
        'created_at', c.created_at
      )
      FROM companies c
      WHERE c.id = p_company_id
    ),
    'statistics', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'category', category,
          'total_count', total_count,
          'active_count', active_count,
          'inactive_count', inactive_count,
          'last_updated', last_updated
        )
      )
      FROM get_company_statistics(p_company_id)
    ),
    'data_integrity', (
      SELECT jsonb_agg(
        jsonb_build_object(
          'issue_type', issue_type,
          'issue_count', issue_count,
          'details', details
        )
      )
      FROM validate_company_integrity(p_company_id)
    )
  ) INTO v_summary;

  RETURN v_summary;
END;
$$ LANGUAGE plpgsql;