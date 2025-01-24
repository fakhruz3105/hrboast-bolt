-- Drop existing policies safely
DO $$ 
BEGIN
  -- Drop evaluation_forms policies if they exist
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_forms' AND policyname = 'evaluation_forms_select'
  ) THEN
    DROP POLICY "evaluation_forms_select" ON evaluation_forms;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_forms' AND policyname = 'evaluation_forms_insert'
  ) THEN
    DROP POLICY "evaluation_forms_insert" ON evaluation_forms;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_forms' AND policyname = 'evaluation_forms_delete'
  ) THEN
    DROP POLICY "evaluation_forms_delete" ON evaluation_forms;
  END IF;

  -- Drop evaluation_responses policies if they exist
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_select'
  ) THEN
    DROP POLICY "evaluation_responses_select" ON evaluation_responses;
  END IF;

  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'evaluation_responses' AND policyname = 'evaluation_responses_insert'
  ) THEN
    DROP POLICY "evaluation_responses_insert" ON evaluation_responses;
  END IF;
END $$;

-- Create or update evaluation_forms table
CREATE TABLE IF NOT EXISTS evaluation_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type evaluation_type NOT NULL,
  questions jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_questions CHECK (jsonb_typeof(questions) = 'array')
);

-- Create or update evaluation_responses table
CREATE TABLE IF NOT EXISTS evaluation_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evaluation_id uuid REFERENCES evaluation_forms(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  manager_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  self_ratings jsonb NOT NULL DEFAULT '{}',
  self_comments jsonb NOT NULL DEFAULT '{}',
  manager_ratings jsonb NOT NULL DEFAULT '{}',
  manager_comments jsonb NOT NULL DEFAULT '{}',
  percentage_score numeric(5,2) CHECK (percentage_score >= 0 AND percentage_score <= 100),
  status evaluation_status NOT NULL DEFAULT 'pending',
  submitted_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_evaluation_responses_evaluation_id ON evaluation_responses(evaluation_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_responses_staff_id ON evaluation_responses(staff_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_responses_manager_id ON evaluation_responses(manager_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_responses_status ON evaluation_responses(status);

-- Create new RLS policies with unique names
CREATE POLICY "evaluation_forms_select_policy_new"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert_policy_new"
  ON evaluation_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_forms_delete_policy_new"
  ON evaluation_forms FOR DELETE
  USING (true);

CREATE POLICY "evaluation_responses_select_policy_new"
  ON evaluation_responses FOR SELECT
  USING (true);

CREATE POLICY "evaluation_responses_insert_policy_new"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_responses_update_policy_new"
  ON evaluation_responses FOR UPDATE
  USING (true);

-- Enable RLS
ALTER TABLE evaluation_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS set_evaluation_forms_updated_at ON evaluation_forms;
CREATE TRIGGER set_evaluation_forms_updated_at
  BEFORE UPDATE ON evaluation_forms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS set_evaluation_responses_updated_at ON evaluation_responses;
CREATE TRIGGER set_evaluation_responses_updated_at
  BEFORE UPDATE ON evaluation_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();