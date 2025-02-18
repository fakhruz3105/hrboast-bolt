DROP TABLE IF EXISTS positions CASCADE;

-- Create positions table with proper company isolation
CREATE TABLE positions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE NOT NULL,
  requirements jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE INDEX idx_positions_department ON positions(department_id);

-- Enable RLS
ALTER TABLE positions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for authenticated users"
  ON positions FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for authenticated users"
  ON positions FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for authenticated users"
  ON positions FOR UPDATE
  USING (true);

CREATE POLICY "Enable delete access for authenticated users"
  ON positions FOR DELETE
  USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_positions_timestamp
  BEFORE UPDATE ON positions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();