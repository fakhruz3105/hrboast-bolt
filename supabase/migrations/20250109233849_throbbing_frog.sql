-- Drop existing tables if they exist
DROP TABLE IF EXISTS kpi_feedback CASCADE;
DROP TABLE IF EXISTS kpis CASCADE;

-- Create KPIs table
CREATE TABLE kpis (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  status kpi_status NOT NULL DEFAULT 'Pending'::kpi_status,
  admin_comment text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_dates CHECK (start_date <= end_date),
  CONSTRAINT valid_assignment CHECK (
    (department_id IS NULL AND staff_id IS NOT NULL) OR
    (department_id IS NOT NULL AND staff_id IS NULL)
  )
);

-- Create KPI feedback table
CREATE TABLE kpi_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kpi_id uuid REFERENCES kpis(id) ON DELETE CASCADE,
  message text NOT NULL,
  is_admin boolean NOT NULL DEFAULT false,
  created_by uuid REFERENCES staff(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_kpis_department ON kpis(department_id);
CREATE INDEX idx_kpis_staff ON kpis(staff_id);
CREATE INDEX idx_kpis_status ON kpis(status);
CREATE INDEX idx_kpi_feedback_kpi ON kpi_feedback(kpi_id);
CREATE INDEX idx_kpi_feedback_created_by ON kpi_feedback(created_by);

-- Enable RLS
ALTER TABLE kpis ENABLE ROW LEVEL SECURITY;
ALTER TABLE kpi_feedback ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "kpis_select"
  ON kpis FOR SELECT
  USING (true);

CREATE POLICY "kpis_insert"
  ON kpis FOR INSERT
  WITH CHECK (true);

CREATE POLICY "kpis_update"
  ON kpis FOR UPDATE
  USING (true);

CREATE POLICY "kpis_delete"
  ON kpis FOR DELETE
  USING (true);

CREATE POLICY "kpi_feedback_select"
  ON kpi_feedback FOR SELECT
  USING (true);

CREATE POLICY "kpi_feedback_insert"
  ON kpi_feedback FOR INSERT
  WITH CHECK (true);

-- Add trigger for updated_at
CREATE TRIGGER set_kpis_timestamp
  BEFORE UPDATE ON kpis
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO kpis (
  title,
  description,
  start_date,
  end_date,
  department_id,
  staff_id,
  status
)
SELECT
  'Increase Team Productivity',
  'Improve team productivity by implementing new processes and tools',
  CURRENT_DATE,
  CURRENT_DATE + interval '3 months',
  d.id,
  NULL,
  'Pending'::kpi_status
FROM departments d
WHERE d.name = 'Engineering'
UNION ALL
SELECT
  'Complete Project Milestones',
  'Successfully deliver all project milestones on time',
  CURRENT_DATE,
  CURRENT_DATE + interval '6 months',
  NULL,
  s.id,
  'Pending'::kpi_status
FROM staff s
WHERE s.email = 'staff@example.com'
LIMIT 2;