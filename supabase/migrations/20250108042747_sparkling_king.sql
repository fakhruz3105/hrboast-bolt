-- Create employee form requests table
CREATE TABLE employee_form_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_name text NOT NULL,
  email text NOT NULL,
  phone_number text NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  form_link text NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  created_at timestamptz DEFAULT now(),
  expires_at timestamptz NOT NULL,
  UNIQUE(email)
);

-- Create employee form responses table
CREATE TABLE employee_form_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid REFERENCES employee_form_requests(id) ON DELETE CASCADE,
  personal_info jsonb NOT NULL,
  education_history jsonb NOT NULL,
  employment_history jsonb NOT NULL,
  emergency_contacts jsonb NOT NULL,
  submitted_at timestamptz DEFAULT now(),
  UNIQUE(request_id)
);

-- Create indexes
CREATE INDEX idx_employee_form_requests_department ON employee_form_requests(department_id);
CREATE INDEX idx_employee_form_requests_level ON employee_form_requests(level_id);
CREATE INDEX idx_employee_form_requests_status ON employee_form_requests(status);
CREATE INDEX idx_employee_form_responses_request ON employee_form_responses(request_id);

-- Enable RLS
ALTER TABLE employee_form_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE employee_form_responses ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "employee_form_requests_select"
  ON employee_form_requests FOR SELECT
  USING (true);

CREATE POLICY "employee_form_requests_insert"
  ON employee_form_requests FOR INSERT
  WITH CHECK (true);

CREATE POLICY "employee_form_responses_select"
  ON employee_form_responses FOR SELECT
  USING (true);

CREATE POLICY "employee_form_responses_insert"
  ON employee_form_responses FOR INSERT
  WITH CHECK (true);