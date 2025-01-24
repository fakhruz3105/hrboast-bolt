-- Create KPI status enum if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'kpi_status') THEN
    CREATE TYPE kpi_status AS ENUM ('Pending', 'Achieved', 'Not Achieved');
  END IF;
END $$;

-- Create KPIs table if it doesn't exist
CREATE TABLE IF NOT EXISTS kpis (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  status kpi_status NOT NULL DEFAULT 'Pending',
  admin_comment text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_dates CHECK (start_date <= end_date),
  CONSTRAINT valid_assignment CHECK (
    (department_id IS NULL AND staff_id IS NOT NULL) OR
    (department_id IS NOT NULL AND staff_id IS NULL)
  )
);

-- Create KPI feedback table if it doesn't exist
CREATE TABLE IF NOT EXISTS kpi_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kpi_id uuid REFERENCES kpis(id) ON DELETE CASCADE,
  message text NOT NULL,
  is_admin boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES staff(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_kpis_department ON kpis(department_id);
CREATE INDEX IF NOT EXISTS idx_kpis_staff ON kpis(staff_id);
CREATE INDEX IF NOT EXISTS idx_kpis_status ON kpis(status);
CREATE INDEX IF NOT EXISTS idx_kpi_feedback_kpi ON kpi_feedback(kpi_id);

-- Enable RLS
ALTER TABLE kpis ENABLE ROW LEVEL SECURITY;
ALTER TABLE kpi_feedback ENABLE ROW LEVEL SECURITY;

-- Create function to get company KPIs
CREATE OR REPLACE FUNCTION get_company_kpis()
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
  GROUP BY k.id, d.name, s.name
  ORDER BY k.created_at DESC;
END;
$$ LANGUAGE plpgsql;