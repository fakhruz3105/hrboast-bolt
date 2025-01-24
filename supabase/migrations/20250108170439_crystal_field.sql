-- Create memo type enum
CREATE TYPE memo_type AS ENUM ('custom', 'bonus', 'salary_increment', 'rewards');

-- Create memos table
CREATE TABLE memos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type memo_type NOT NULL,
  content text NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE SET NULL,
  staff_id uuid REFERENCES staff(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_recipient CHECK (
    (department_id IS NULL AND staff_id IS NULL) OR -- All staff
    (department_id IS NOT NULL AND staff_id IS NULL) OR -- Department only
    (department_id IS NULL AND staff_id IS NOT NULL) -- Individual staff only
  )
);

-- Create indexes
CREATE INDEX idx_memos_department ON memos(department_id);
CREATE INDEX idx_memos_staff ON memos(staff_id);
CREATE INDEX idx_memos_type ON memos(type);
CREATE INDEX idx_memos_created_at ON memos(created_at);

-- Enable RLS
ALTER TABLE memos ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "memos_select"
  ON memos FOR SELECT
  USING (true);

CREATE POLICY "memos_insert"
  ON memos FOR INSERT
  WITH CHECK (true);

CREATE POLICY "memos_delete"
  ON memos FOR DELETE
  USING (true);

-- Add trigger for updated_at
CREATE TRIGGER set_memos_timestamp
  BEFORE UPDATE ON memos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();