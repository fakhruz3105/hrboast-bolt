/*
  # Fix Evaluation Relationships

  1. Changes
    - Add missing foreign key relationships for evaluation forms
    - Update evaluation responses table structure
    - Add proper indexes and constraints

  2. Security
    - Enable RLS on all tables
    - Add appropriate policies
*/

-- Drop existing policies
DROP POLICY IF EXISTS "evaluation_forms_select_policy_new" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_forms_insert_policy_new" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_forms_delete_policy_new" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_responses_select_policy_new" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_insert_policy_new" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_update_policy_new" ON evaluation_responses;

-- Recreate evaluation_forms table with proper relationships
DROP TABLE IF EXISTS evaluation_responses;
DROP TABLE IF EXISTS evaluation_forms CASCADE;

CREATE TABLE evaluation_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type evaluation_type NOT NULL,
  questions jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_questions CHECK (jsonb_typeof(questions) = 'array')
);

-- Create evaluation_responses with proper relationships
CREATE TABLE evaluation_responses (
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
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_ratings CHECK (jsonb_typeof(self_ratings) = 'object'),
  CONSTRAINT valid_self_comments CHECK (jsonb_typeof(self_comments) = 'object'),
  CONSTRAINT valid_manager_ratings CHECK (jsonb_typeof(manager_ratings) = 'object'),
  CONSTRAINT valid_manager_comments CHECK (jsonb_typeof(manager_comments) = 'object')
);

-- Create indexes
CREATE INDEX idx_evaluation_responses_evaluation ON evaluation_responses(evaluation_id);
CREATE INDEX idx_evaluation_responses_staff ON evaluation_responses(staff_id);
CREATE INDEX idx_evaluation_responses_manager ON evaluation_responses(manager_id);
CREATE INDEX idx_evaluation_responses_status ON evaluation_responses(status);
CREATE INDEX idx_evaluation_forms_type ON evaluation_forms(type);

-- Enable RLS
ALTER TABLE evaluation_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "evaluation_forms_select"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert"
  ON evaluation_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_forms_delete"
  ON evaluation_forms FOR DELETE
  USING (true);

CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (true);

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_responses_update"
  ON evaluation_responses FOR UPDATE
  USING (true);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp
  BEFORE UPDATE ON evaluation_forms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_timestamp
  BEFORE UPDATE ON evaluation_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();