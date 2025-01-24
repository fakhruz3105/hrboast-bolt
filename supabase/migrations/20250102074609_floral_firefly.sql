-- First check if tables exist
CREATE TABLE IF NOT EXISTS evaluation_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type evaluation_type NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  questions jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users on evaluation_forms" ON evaluation_forms;
DROP POLICY IF EXISTS "Enable insert access for all users on evaluation_forms" ON evaluation_forms;
DROP POLICY IF EXISTS "Enable read access for all users on evaluation_responses" ON evaluation_responses;
DROP POLICY IF EXISTS "Enable insert access for all users on evaluation_responses" ON evaluation_responses;

-- Function to calculate percentage score
CREATE OR REPLACE FUNCTION calculate_evaluation_percentage(
  manager_ratings jsonb,
  max_rating integer DEFAULT 5
) RETURNS numeric AS $$
DECLARE
  total_score numeric;
  max_possible_score numeric;
  num_ratings integer;
BEGIN
  SELECT sum((value#>>'{}'::text[])::numeric)
  INTO total_score
  FROM jsonb_each(manager_ratings);

  SELECT count(*)
  INTO num_ratings
  FROM jsonb_each(manager_ratings);

  max_possible_score := num_ratings * max_rating;
  RETURN ROUND((total_score / max_possible_score * 100)::numeric, 2);
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically calculate percentage score
CREATE OR REPLACE FUNCTION update_evaluation_percentage()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.manager_ratings IS NOT NULL AND NEW.manager_ratings != '{}'::jsonb THEN
    NEW.percentage_score := calculate_evaluation_percentage(NEW.manager_ratings);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for percentage calculation
DROP TRIGGER IF EXISTS calculate_percentage_score ON evaluation_responses;
CREATE TRIGGER calculate_percentage_score
  BEFORE INSERT OR UPDATE OF manager_ratings ON evaluation_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_percentage();

-- Create new RLS policies with unique names
CREATE POLICY "evaluation_forms_select"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert"
  ON evaluation_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (true);

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);

-- Add constraint if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.table_constraints 
    WHERE constraint_name = 'valid_questions' 
    AND table_name = 'evaluation_forms'
  ) THEN
    ALTER TABLE evaluation_forms
    ADD CONSTRAINT valid_questions CHECK (jsonb_typeof(questions) = 'array');
  END IF;
END $$;