-- Drop and recreate staff_interview_forms table with proper structure
DROP TABLE IF EXISTS staff_interview_forms;

CREATE TABLE staff_interview_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  interview_id uuid REFERENCES staff_interviews(id) ON DELETE CASCADE,
  personal_info jsonb NOT NULL,
  education_history jsonb NOT NULL,
  work_experience jsonb NOT NULL,
  emergency_contacts jsonb NOT NULL,
  submitted_at timestamptz DEFAULT now(),
  UNIQUE(interview_id)
);

-- Enable RLS
ALTER TABLE staff_interview_forms ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users"
  ON staff_interview_forms FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON staff_interview_forms FOR INSERT
  WITH CHECK (true);

-- Insert dummy data
INSERT INTO staff_interview_forms (
  interview_id,
  personal_info,
  education_history,
  work_experience,
  emergency_contacts,
  submitted_at
)
SELECT
  id as interview_id,
  jsonb_build_object(
    'fullName', staff_name,
    'email', email,
    'nricPassport', '123456',
    'dateOfBirth', '1990-01-01',
    'gender', 'male',
    'nationality', 'Malaysian',
    'address', '123 Main Street',
    'phone', '+60123456789'
  ) as personal_info,
  jsonb_build_array(
    jsonb_build_object(
      'institution', 'University of Malaysia',
      'qualification', 'Bachelor Degree',
      'fieldOfStudy', 'Computer Science',
      'graduationYear', '2015'
    )
  ) as education_history,
  jsonb_build_array(
    jsonb_build_object(
      'company', 'Tech Corp',
      'position', 'Software Engineer',
      'startDate', '2015-01-01',
      'endDate', '2020-12-31',
      'responsibilities', 'Development and maintenance of web applications'
    )
  ) as work_experience,
  jsonb_build_array(
    jsonb_build_object(
      'name', 'Emergency Contact',
      'relationship', 'Parent',
      'phone', '+60123456789',
      'address', '456 Second Street'
    )
  ) as emergency_contacts,
  now() - (random() * interval '30 days') as submitted_at
FROM staff_interviews
WHERE status = 'completed'
  AND NOT EXISTS (
    SELECT 1 FROM staff_interview_forms WHERE staff_interview_forms.interview_id = staff_interviews.id
  );