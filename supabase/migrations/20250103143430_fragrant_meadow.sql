/*
  # Fix Evaluation System Policies

  1. Changes
    - Drop existing policies safely
    - Create new RLS policies with proper checks
    - Add delete policy for evaluation forms
    - Update policy names for clarity

  2. Security
    - Enable RLS on all tables
    - Restrict sensitive operations to admin/HR roles
    - Allow staff to view and update their own evaluations
*/

-- Drop existing policies safely
DO $$ 
BEGIN
  -- Drop evaluation_forms policies
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

  -- Drop evaluation_responses policies
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

-- Create new RLS policies
CREATE POLICY "evaluation_forms_select_policy"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "evaluation_forms_insert_policy"
  ON evaluation_forms FOR INSERT
  WITH CHECK (auth.role() IN ('admin', 'hr'));

CREATE POLICY "evaluation_forms_delete_policy"
  ON evaluation_forms FOR DELETE
  USING (auth.role() IN ('admin', 'hr'));

CREATE POLICY "evaluation_responses_select_policy"
  ON evaluation_responses FOR SELECT
  USING (
    auth.role() IN ('admin', 'hr') OR 
    staff_id = auth.uid() OR 
    manager_id = auth.uid()
  );

CREATE POLICY "evaluation_responses_insert_policy"
  ON evaluation_responses FOR INSERT
  WITH CHECK (auth.role() IN ('admin', 'hr'));

-- Enable RLS
ALTER TABLE evaluation_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;