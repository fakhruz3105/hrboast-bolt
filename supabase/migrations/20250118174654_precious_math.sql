-- First drop existing function to avoid conflicts
DROP FUNCTION IF EXISTS get_company_kpis(uuid);

-- First delete existing data to avoid constraint violations
DELETE FROM kpi_feedback;
DELETE FROM kpis;

-- Add period column to KPIs table with a default value
ALTER TABLE kpis
ADD COLUMN period text NOT NULL DEFAULT 'Q1' CHECK (period IN ('Q1', 'Q2', 'Q3', 'Q4', 'yearly'));

-- Create new function with updated signature
CREATE OR REPLACE FUNCTION get_company_kpis(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  period text,
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
    k.period,
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