/*
  # Fix Evaluation Forms and Departments Relationship

  1. Changes
    - Drop existing evaluation_form_departments table
    - Create new evaluation_form_departments table with proper constraints
    - Add indexes and triggers
    - Update RLS policies

  2. Security
    - Enable RLS
    - Add policies for access control
*/

-- Drop existing table if it exists
DROP TABLE IF EXISTS evaluation_form_departments;

-- Create evaluation_form_departments table
CREATE TABLE evaluation_form_departments (
  evaluation_id uuid REFERENCES evaluation_forms(id) ON DELETE CASCADE,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (evaluation_id, department_id)
);

-- Create indexes
CREATE INDEX idx_eval_form_depts_eval ON evaluation_form_departments(evaluation_id);
CREATE INDEX idx_eval_form_depts_dept ON evaluation_form_departments(department_id);

-- Enable RLS
ALTER TABLE evaluation_form_departments ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "evaluation_form_departments_select"
  ON evaluation_form_departments FOR SELECT
  USING (true);

CREATE POLICY "evaluation_form_departments_insert"
  ON evaluation_form_departments FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_form_departments_delete"
  ON evaluation_form_departments FOR DELETE
  USING (true);

-- Create function to get departments for an evaluation form
CREATE OR REPLACE FUNCTION get_evaluation_departments(evaluation_id uuid)
RETURNS TABLE (
  department_id uuid,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT d.id, d.name
  FROM departments d
  JOIN evaluation_form_departments efd ON d.id = efd.department_id
  WHERE efd.evaluation_id = $1;
END;
$$ LANGUAGE plpgsql;

-- Create function to get evaluations for a department
CREATE OR REPLACE FUNCTION get_department_evaluations(dept_id uuid)
RETURNS TABLE (
  evaluation_id uuid,
  title text,
  type text,
  created_at timestamptz
) AS $$
BEGIN
  RETURN QUERY
  SELECT ef.id, ef.title, ef.type::text, ef.created_at
  FROM evaluation_forms ef
  JOIN evaluation_form_departments efd ON ef.id = efd.evaluation_id
  WHERE efd.department_id = dept_id
  ORDER BY ef.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to update evaluation_forms updated_at
CREATE OR REPLACE FUNCTION update_evaluation_form_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE evaluation_forms
  SET updated_at = now()
  WHERE id = NEW.evaluation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_evaluation_form_timestamp
  AFTER INSERT OR DELETE ON evaluation_form_departments
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_form_timestamp();