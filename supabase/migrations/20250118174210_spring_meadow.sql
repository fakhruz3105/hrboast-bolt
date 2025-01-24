-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "kpis_select_policy_v1" ON kpis;
  DROP POLICY IF EXISTS "kpis_insert_policy_v1" ON kpis;
  DROP POLICY IF EXISTS "kpis_update_policy_v1" ON kpis;
  DROP POLICY IF EXISTS "kpis_delete_policy_v1" ON kpis;
  DROP POLICY IF EXISTS "kpi_feedback_select_policy_v1" ON kpi_feedback;
  DROP POLICY IF EXISTS "kpi_feedback_insert_policy_v1" ON kpi_feedback;
END $$;

-- Create RLS policies with unique names
CREATE POLICY "kpis_select_policy_v2"
  ON kpis FOR SELECT
  USING (true);

CREATE POLICY "kpis_insert_policy_v2"
  ON kpis FOR INSERT
  WITH CHECK (true);

CREATE POLICY "kpis_update_policy_v2"
  ON kpis FOR UPDATE
  USING (true);

CREATE POLICY "kpis_delete_policy_v2"
  ON kpis FOR DELETE
  USING (true);

CREATE POLICY "kpi_feedback_select_policy_v2"
  ON kpi_feedback FOR SELECT
  USING (true);

CREATE POLICY "kpi_feedback_insert_policy_v2"
  ON kpi_feedback FOR INSERT
  WITH CHECK (true);

-- Add company_id column to KPIs table
ALTER TABLE kpis
ADD COLUMN IF NOT EXISTS company_id uuid REFERENCES companies(id) ON DELETE CASCADE;

-- Create index for company_id
CREATE INDEX IF NOT EXISTS idx_kpis_company ON kpis(company_id);

-- Update get_company_kpis function to include company isolation
CREATE OR REPLACE FUNCTION get_company_kpis(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  start_date date,
  end_date date,
  department_name text,
  staff_name text,
  status text,
  admin_comment text,
  created_at timestamptz,
  updated_at timestamptz,
  feedback jsonb
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    k.id,
    k.title,
    k.description,
    k.start_date,
    k.end_date,
    d.name as department_name,
    s.name as staff_name,
    k.status::text,
    k.admin_comment,
    k.created_at,
    k.updated_at,
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id', f.id,
          'message', f.message,
          'created_at', f.created_at,
          'created_by', f.created_by,
          'is_admin', f.is_admin
        )
      ) FILTER (WHERE f.id IS NOT NULL),
      '[]'::jsonb
    ) as feedback
  FROM kpis k
  LEFT JOIN departments d ON k.department_id = d.id
  LEFT JOIN staff s ON k.staff_id = s.id
  LEFT JOIN kpi_feedback f ON k.id = f.kpi_id
  WHERE k.company_id = p_company_id
  GROUP BY k.id, d.name, s.name
  ORDER BY k.created_at DESC;
END;
$$ LANGUAGE plpgsql;