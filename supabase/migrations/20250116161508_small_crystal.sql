-- Create table to store schema backups
CREATE TABLE IF NOT EXISTS schema_backups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  backup_date timestamptz DEFAULT now(),
  backup_type text NOT NULL,
  backup_data jsonb NOT NULL,
  created_by uuid REFERENCES staff(id) ON DELETE SET NULL,
  restored_at timestamptz,
  restored_by uuid REFERENCES staff(id) ON DELETE SET NULL
);

-- Create indexes for better performance
CREATE INDEX idx_schema_backups_company ON schema_backups(company_id);
CREATE INDEX idx_schema_backups_date ON schema_backups(backup_date);
CREATE INDEX idx_schema_backups_type ON schema_backups(backup_type);

-- Enable RLS
ALTER TABLE schema_backups ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "schema_backups_select"
  ON schema_backups FOR SELECT
  USING (true);

CREATE POLICY "schema_backups_insert"
  ON schema_backups FOR INSERT
  WITH CHECK (true);

-- Create function to backup company data
CREATE OR REPLACE FUNCTION backup_company_data(
  p_company_id uuid,
  p_backup_type text,
  p_user_id uuid
)
RETURNS uuid AS $$
DECLARE
  v_schema_name text;
  v_backup_id uuid;
  v_backup_data jsonb;
BEGIN
  -- Get schema name
  SELECT schema_name INTO v_schema_name
  FROM companies
  WHERE id = p_company_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Company schema not found';
  END IF;

  -- Collect all data from company schema
  EXECUTE format('
    WITH schema_data AS (
      SELECT 
        jsonb_build_object(
          ''staff'', (
            SELECT jsonb_agg(row_to_json(s))
            FROM %1$I.staff s
          ),
          ''staff_departments'', (
            SELECT jsonb_agg(row_to_json(sd))
            FROM %1$I.staff_departments sd
          ),
          ''staff_levels_junction'', (
            SELECT jsonb_agg(row_to_json(sl))
            FROM %1$I.staff_levels_junction sl
          ),
          ''benefits'', (
            SELECT jsonb_agg(row_to_json(b))
            FROM %1$I.benefits b
          ),
          ''benefit_eligibility'', (
            SELECT jsonb_agg(row_to_json(be))
            FROM %1$I.benefit_eligibility be
          ),
          ''benefit_claims'', (
            SELECT jsonb_agg(row_to_json(bc))
            FROM %1$I.benefit_claims bc
          ),
          ''evaluation_forms'', (
            SELECT jsonb_agg(row_to_json(ef))
            FROM %1$I.evaluation_forms ef
          ),
          ''evaluation_responses'', (
            SELECT jsonb_agg(row_to_json(er))
            FROM %1$I.evaluation_responses er
          ),
          ''warning_letters'', (
            SELECT jsonb_agg(row_to_json(wl))
            FROM %1$I.warning_letters wl
          ),
          ''hr_letters'', (
            SELECT jsonb_agg(row_to_json(hl))
            FROM %1$I.hr_letters hl
          ),
          ''memos'', (
            SELECT jsonb_agg(row_to_json(m))
            FROM %1$I.memos m
          )
        ) as data
    )
    SELECT data INTO %L FROM schema_data',
    v_schema_name
  ) INTO v_backup_data;

  -- Create backup record
  INSERT INTO schema_backups (
    company_id,
    backup_type,
    backup_data,
    created_by
  ) VALUES (
    p_company_id,
    p_backup_type,
    v_backup_data,
    p_user_id
  ) RETURNING id INTO v_backup_id;

  RETURN v_backup_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to restore company data from backup
CREATE OR REPLACE FUNCTION restore_company_data(
  p_backup_id uuid,
  p_user_id uuid
)
RETURNS void AS $$
DECLARE
  v_schema_name text;
  v_company_id uuid;
  v_backup_data jsonb;
BEGIN
  -- Get backup details
  SELECT 
    b.company_id,
    b.backup_data,
    c.schema_name
  INTO v_company_id, v_backup_data, v_schema_name
  FROM schema_backups b
  JOIN companies c ON b.company_id = c.id
  WHERE b.id = p_backup_id;

  IF v_schema_name IS NULL THEN
    RAISE EXCEPTION 'Backup not found or company schema missing';
  END IF;

  -- Start transaction
  BEGIN
    -- Clear existing data
    EXECUTE format('TRUNCATE TABLE %I.memos CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.hr_letters CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.warning_letters CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.evaluation_responses CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.evaluation_forms CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefit_claims CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefit_eligibility CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.benefits CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff_levels_junction CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff_departments CASCADE', v_schema_name);
    EXECUTE format('TRUNCATE TABLE %I.staff CASCADE', v_schema_name);

    -- Restore data
    EXECUTE format('
      -- Restore staff
      INSERT INTO %1$I.staff 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff, %2$L);
      
      -- Restore staff departments
      INSERT INTO %1$I.staff_departments 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff_departments, %3$L);
      
      -- Restore staff levels
      INSERT INTO %1$I.staff_levels_junction 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.staff_levels_junction, %4$L);
      
      -- Restore benefits
      INSERT INTO %1$I.benefits 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefits, %5$L);
      
      -- Restore benefit eligibility
      INSERT INTO %1$I.benefit_eligibility 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefit_eligibility, %6$L);
      
      -- Restore benefit claims
      INSERT INTO %1$I.benefit_claims 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.benefit_claims, %7$L);
      
      -- Restore evaluation forms
      INSERT INTO %1$I.evaluation_forms 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.evaluation_forms, %8$L);
      
      -- Restore evaluation responses
      INSERT INTO %1$I.evaluation_responses 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.evaluation_responses, %9$L);
      
      -- Restore warning letters
      INSERT INTO %1$I.warning_letters 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.warning_letters, %10$L);
      
      -- Restore HR letters
      INSERT INTO %1$I.hr_letters 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.hr_letters, %11$L);
      
      -- Restore memos
      INSERT INTO %1$I.memos 
      SELECT * FROM jsonb_populate_recordset(null::%1$I.memos, %12$L)',
      v_schema_name,
      v_backup_data->'staff',
      v_backup_data->'staff_departments',
      v_backup_data->'staff_levels_junction',
      v_backup_data->'benefits',
      v_backup_data->'benefit_eligibility',
      v_backup_data->'benefit_claims',
      v_backup_data->'evaluation_forms',
      v_backup_data->'evaluation_responses',
      v_backup_data->'warning_letters',
      v_backup_data->'hr_letters',
      v_backup_data->'memos'
    );

    -- Update backup record
    UPDATE schema_backups
    SET 
      restored_at = now(),
      restored_by = p_user_id
    WHERE id = p_backup_id;

    -- Commit transaction
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    -- Rollback transaction on error
    ROLLBACK;
    RAISE;
  END;
END;
$$ LANGUAGE plpgsql;

-- Create function to list available backups
CREATE OR REPLACE FUNCTION list_company_backups(
  p_company_id uuid
)
RETURNS TABLE (
  backup_id uuid,
  backup_type text,
  backup_date timestamptz,
  created_by_name text,
  restored_at timestamptz,
  restored_by_name text,
  table_counts jsonb
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.id as backup_id,
    b.backup_type,
    b.backup_date,
    c.name as created_by_name,
    b.restored_at,
    r.name as restored_by_name,
    jsonb_build_object(
      'staff', jsonb_array_length(b.backup_data->'staff'),
      'benefits', jsonb_array_length(b.backup_data->'benefits'),
      'evaluations', jsonb_array_length(b.backup_data->'evaluation_forms'),
      'warning_letters', jsonb_array_length(b.backup_data->'warning_letters'),
      'hr_letters', jsonb_array_length(b.backup_data->'hr_letters'),
      'memos', jsonb_array_length(b.backup_data->'memos')
    ) as table_counts
  FROM schema_backups b
  LEFT JOIN staff c ON b.created_by = c.id
  LEFT JOIN staff r ON b.restored_by = r.id
  WHERE b.company_id = p_company_id
  ORDER BY b.backup_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to cleanup old backups
CREATE OR REPLACE FUNCTION cleanup_old_backups(
  p_company_id uuid,
  p_days_to_keep integer DEFAULT 30
)
RETURNS integer AS $$
DECLARE
  v_deleted_count integer;
BEGIN
  WITH deleted AS (
    DELETE FROM schema_backups
    WHERE company_id = p_company_id
    AND backup_date < now() - (p_days_to_keep || ' days')::interval
    AND restored_at IS NOT NULL
    RETURNING id
  )
  SELECT count(*) INTO v_deleted_count FROM deleted;

  RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;