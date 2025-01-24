-- Drop existing policies if they exist
DROP POLICY IF EXISTS "kpi_feedback_select" ON kpi_feedback;
DROP POLICY IF EXISTS "kpi_feedback_insert" ON kpi_feedback;

-- Create KPI feedback table if it doesn't exist
CREATE TABLE IF NOT EXISTS kpi_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kpi_id uuid REFERENCES kpis(id) ON DELETE CASCADE,
  message text NOT NULL,
  is_admin boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES staff(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_kpi_feedback_kpi ON kpi_feedback(kpi_id);
CREATE INDEX IF NOT EXISTS idx_kpi_feedback_created_by ON kpi_feedback(created_by);

-- Enable RLS
ALTER TABLE kpi_feedback ENABLE ROW LEVEL SECURITY;

-- Create new RLS policies with unique names
CREATE POLICY "kpi_feedback_select_policy"
  ON kpi_feedback FOR SELECT
  USING (true);

CREATE POLICY "kpi_feedback_insert_policy"
  ON kpi_feedback FOR INSERT
  WITH CHECK (true);

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS set_kpi_feedback_timestamp ON kpi_feedback;
CREATE TRIGGER set_kpi_feedback_timestamp
  BEFORE UPDATE ON kpi_feedback
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Update KPIs query function to include feedback
CREATE OR REPLACE FUNCTION get_staff_kpis(p_staff_id uuid)
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  start_date date,
  end_date date,
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
  LEFT JOIN kpi_feedback f ON k.id = f.kpi_id
  WHERE 
    k.staff_id = p_staff_id OR
    (k.department_id IN (
      SELECT department_id 
      FROM staff_departments 
      WHERE staff_id = p_staff_id
    ) AND k.staff_id IS NULL)
  GROUP BY k.id
  ORDER BY k.created_at DESC;
END;
$$ LANGUAGE plpgsql;