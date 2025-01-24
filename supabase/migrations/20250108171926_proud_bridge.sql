-- Create memo type enum if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'memo_type') THEN
    CREATE TYPE memo_type AS ENUM ('custom', 'bonus', 'salary_increment', 'rewards');
  END IF;
END $$;

-- Create memos table
CREATE TABLE IF NOT EXISTS memos (
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

-- Create indexes if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_memos_department') THEN
    CREATE INDEX idx_memos_department ON memos(department_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_memos_staff') THEN
    CREATE INDEX idx_memos_staff ON memos(staff_id);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_memos_type') THEN
    CREATE INDEX idx_memos_type ON memos(type);
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_memos_created_at') THEN
    CREATE INDEX idx_memos_created_at ON memos(created_at);
  END IF;
END $$;

-- Enable RLS
ALTER TABLE memos ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "memos_select" ON memos;
DROP POLICY IF EXISTS "memos_insert" ON memos;
DROP POLICY IF EXISTS "memos_delete" ON memos;

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

-- Add trigger for updated_at if it doesn't exist
DROP TRIGGER IF EXISTS set_memos_timestamp ON memos;
CREATE TRIGGER set_memos_timestamp
  BEFORE UPDATE ON memos
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();