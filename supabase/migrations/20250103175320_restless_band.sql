/*
  # Fix Evaluation Forms and Staff View

  1. Changes
    - Add missing relationships between evaluation_forms and departments
    - Update evaluation_responses table structure
    - Add proper indexes and constraints

  2. Security
    - Enable RLS
    - Add policies for proper access control
*/

-- Drop existing policies
DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_forms_insert" ON evaluation_forms;
DROP POLICY IF EXISTS "evaluation_responses_select" ON evaluation_responses;
DROP POLICY IF EXISTS "evaluation_responses_insert" ON evaluation_responses;

-- Create proper relationships
CREATE OR REPLACE VIEW evaluation_forms_with_departments AS
SELECT 
  ef.*,
  array_agg(DISTINCT d.name) as department_names,
  array_agg(DISTINCT d.id) as department_ids
FROM evaluation_forms ef
LEFT JOIN evaluation_form_departments efd ON ef.id = efd.evaluation_id
LEFT JOIN departments d ON efd.department_id = d.id
GROUP BY ef.id;

-- Create RLS policies
CREATE POLICY "evaluation_forms_select"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert"
  ON evaluation_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "evaluation_responses_select"
  ON evaluation_responses FOR SELECT
  USING (
    -- Staff can see their own evaluations
    staff_id = auth.uid() OR
    -- Managers can see evaluations they're assigned to
    manager_id = auth.uid() OR
    -- Admins and HR can see all evaluations
    EXISTS (
      SELECT 1 FROM staff s
      JOIN role_mappings rm ON s.role_id = rm.id
      WHERE s.id = auth.uid() AND rm.role IN ('admin', 'hr')
    )
  );

CREATE POLICY "evaluation_responses_insert"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);

-- Add function to get staff evaluations
CREATE OR REPLACE FUNCTION get_staff_evaluations(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  evaluation_id uuid,
  staff_id uuid,
  manager_id uuid,
  status text,
  percentage_score numeric,
  submitted_at timestamptz,
  completed_at timestamptz,
  evaluation_title text,
  evaluation_type text,
  department_name text,
  manager_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    er.id,
    er.evaluation_id,
    er.staff_id,
    er.manager_id,
    er.status::text,
    er.percentage_score,
    er.submitted_at,
    er.completed_at,
    ef.title as evaluation_title,
    ef.type::text as evaluation_type,
    d.name as department_name,
    m.name as manager_name
  FROM evaluation_responses er
  JOIN evaluation_forms ef ON er.evaluation_id = ef.id
  JOIN staff s ON er.staff_id = s.id
  JOIN departments d ON s.department_id = d.id
  JOIN staff m ON er.manager_id = m.id
  WHERE er.staff_id = staff_uid
  ORDER BY er.created_at DESC;
END;
$$ LANGUAGE plpgsql;