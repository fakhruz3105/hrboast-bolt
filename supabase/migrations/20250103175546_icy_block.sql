/*
  # Add Staff Levels to Evaluation Forms

  1. Changes
    - Create junction table for evaluation forms and staff levels
    - Add indexes for performance
    - Add helper functions
    - Update RLS policies

  2. Security
    - Enable RLS
    - Add policies for proper access control
*/

-- Create junction table for evaluation forms and staff levels
CREATE TABLE evaluation_form_levels (
  evaluation_id uuid REFERENCES evaluation_forms(id) ON DELETE CASCADE,
  level_id uuid REFERENCES staff_levels(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (evaluation_id, level_id)
);

-- Create indexes for better performance
CREATE INDEX idx_eval_form_levels_eval ON evaluation_form_levels(evaluation_id);
CREATE INDEX idx_eval_form_levels_level ON evaluation_form_levels(level_id);

-- Enable RLS
ALTER TABLE evaluation_form_levels ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "evaluation_form_levels_select"
  ON evaluation_form_levels FOR SELECT
  USING (true);

CREATE POLICY "evaluation_form_levels_insert"
  ON evaluation_form_levels FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_form_levels_delete"
  ON evaluation_form_levels FOR DELETE
  USING (true);

-- Update view to include staff levels
CREATE OR REPLACE VIEW evaluation_forms_with_details AS
SELECT 
  ef.*,
  array_agg(DISTINCT d.name) as department_names,
  array_agg(DISTINCT d.id) as department_ids,
  array_agg(DISTINCT sl.name) as level_names,
  array_agg(DISTINCT sl.id) as level_ids
FROM evaluation_forms ef
LEFT JOIN evaluation_form_departments efd ON ef.id = efd.evaluation_id
LEFT JOIN departments d ON efd.department_id = d.id
LEFT JOIN evaluation_form_levels efl ON ef.id = efl.evaluation_id
LEFT JOIN staff_levels sl ON efl.level_id = sl.id
GROUP BY ef.id;

-- Add function to get staff levels for an evaluation form
CREATE OR REPLACE FUNCTION get_evaluation_levels(evaluation_id uuid)
RETURNS TABLE (
  level_id uuid,
  level_name text,
  level_rank integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT sl.id, sl.name, sl.rank
  FROM staff_levels sl
  JOIN evaluation_form_levels efl ON sl.id = efl.level_id
  WHERE efl.evaluation_id = $1
  ORDER BY sl.rank;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to update evaluation_forms updated_at
CREATE OR REPLACE FUNCTION update_evaluation_form_levels_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_evaluation_form_levels_timestamp
  AFTER INSERT OR DELETE ON evaluation_form_levels
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_form_levels_timestamp();