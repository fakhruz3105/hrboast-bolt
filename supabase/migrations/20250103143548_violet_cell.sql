/*
  # Add Evaluation-Department Relationships

  1. New Tables
    - evaluation_departments: Junction table for many-to-many relationship between evaluations and departments
      - evaluation_id (uuid, references evaluation_forms)
      - department_id (uuid, references departments)

  2. Security
    - Enable RLS on new table
    - Add policies for read/write access

  3. Changes
    - Add foreign key constraints
    - Add indexes for performance
*/

-- Create junction table for evaluation forms and departments
CREATE TABLE evaluation_departments (
  evaluation_id uuid REFERENCES evaluation_forms(id) ON DELETE CASCADE,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (evaluation_id, department_id)
);

-- Create indexes for better performance
CREATE INDEX idx_evaluation_departments_evaluation ON evaluation_departments(evaluation_id);
CREATE INDEX idx_evaluation_departments_department ON evaluation_departments(department_id);

-- Enable RLS
ALTER TABLE evaluation_departments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "evaluation_departments_select_policy"
  ON evaluation_departments FOR SELECT
  USING (true);

CREATE POLICY "evaluation_departments_insert_policy"
  ON evaluation_departments FOR INSERT
  WITH CHECK (auth.role() IN ('admin', 'hr'));

CREATE POLICY "evaluation_departments_delete_policy"
  ON evaluation_departments FOR DELETE
  USING (auth.role() IN ('admin', 'hr'));

-- Add trigger to update evaluation_forms updated_at
CREATE OR REPLACE FUNCTION update_evaluation_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_evaluation_timestamp
  AFTER INSERT OR DELETE ON evaluation_departments
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_updated_at();