-- Create KPI status enum
CREATE TYPE kpi_status AS ENUM ('pending', 'in_progress', 'completed', 'overdue');

-- Create KPI table
CREATE TABLE kpis (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  target_value numeric NOT NULL,
  current_value numeric DEFAULT 0,
  unit text NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  status kpi_status DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_dates CHECK (start_date <= end_date),
  CONSTRAINT valid_values CHECK (current_value >= 0 AND target_value > 0),
  CONSTRAINT valid_assignment CHECK (
    (department_id IS NULL AND staff_id IS NOT NULL) OR -- Individual KPI
    (department_id IS NOT NULL AND staff_id IS NULL)    -- Department KPI
  )
);

-- Create KPI updates table for tracking progress
CREATE TABLE kpi_updates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  kpi_id uuid REFERENCES kpis(id) ON DELETE CASCADE,
  value numeric NOT NULL,
  notes text,
  updated_by uuid REFERENCES staff(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_kpis_department ON kpis(department_id);
CREATE INDEX idx_kpis_staff ON kpis(staff_id);
CREATE INDEX idx_kpis_status ON kpis(status);
CREATE INDEX idx_kpis_dates ON kpis(start_date, end_date);
CREATE INDEX idx_kpi_updates_kpi ON kpi_updates(kpi_id);

-- Enable RLS
ALTER TABLE kpis ENABLE ROW LEVEL SECURITY;
ALTER TABLE kpi_updates ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "kpis_select" ON kpis FOR SELECT USING (true);
CREATE POLICY "kpis_insert" ON kpis FOR INSERT WITH CHECK (true);
CREATE POLICY "kpis_update" ON kpis FOR UPDATE USING (true);
CREATE POLICY "kpis_delete" ON kpis FOR DELETE USING (true);

CREATE POLICY "kpi_updates_select" ON kpi_updates FOR SELECT USING (true);
CREATE POLICY "kpi_updates_insert" ON kpi_updates FOR INSERT WITH CHECK (true);

-- Add trigger for updated_at
CREATE TRIGGER set_kpis_timestamp
  BEFORE UPDATE ON kpis
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();