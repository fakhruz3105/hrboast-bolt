-- Create enum for letter types
CREATE TYPE letter_type AS ENUM ('warning', 'evaluation', 'interview', 'notice');
CREATE TYPE letter_status AS ENUM ('draft', 'submitted', 'pending', 'signed');

-- Create HR letters table
CREATE TABLE hr_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  title text NOT NULL,
  type letter_type NOT NULL,
  content jsonb NOT NULL DEFAULT '{}',
  document_url text,
  issued_date timestamptz NOT NULL DEFAULT now(),
  status letter_status NOT NULL DEFAULT 'submitted',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_content CHECK (jsonb_typeof(content) = 'object')
);

-- Create indexes
CREATE INDEX idx_hr_letters_staff ON hr_letters(staff_id);
CREATE INDEX idx_hr_letters_type ON hr_letters(type);
CREATE INDEX idx_hr_letters_status ON hr_letters(status);
CREATE INDEX idx_hr_letters_issued_date ON hr_letters(issued_date);

-- Enable RLS
ALTER TABLE hr_letters ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "hr_letters_select"
  ON hr_letters FOR SELECT
  USING (
    -- Staff can view their own letters
    staff_id = auth.uid() OR
    -- Admins and HR can view all letters
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "hr_letters_insert"
  ON hr_letters FOR INSERT
  WITH CHECK (
    -- Only admins and HR can create letters
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "hr_letters_update"
  ON hr_letters FOR UPDATE
  USING (
    -- Only admins and HR can update letters
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

-- Create trigger for updated_at
CREATE TRIGGER set_hr_letters_updated_at
  BEFORE UPDATE ON hr_letters
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample data
INSERT INTO hr_letters (
  staff_id,
  title,
  type,
  content,
  status,
  issued_date
)
SELECT
  s.id as staff_id,
  'Welcome Letter',
  'notice',
  jsonb_build_object(
    'message', 'Welcome to the company!',
    'details', 'We are excited to have you join our team.'
  ),
  'submitted',
  s.join_date
FROM staff s
WHERE s.status = 'probation'
LIMIT 3;