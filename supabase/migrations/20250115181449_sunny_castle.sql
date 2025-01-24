-- Add type field to content JSONB column
ALTER TABLE hr_letters
DROP CONSTRAINT IF EXISTS valid_content;

-- Add check constraint to ensure content has correct structure
ALTER TABLE hr_letters
ADD CONSTRAINT valid_content CHECK (
  CASE 
    WHEN type = 'interview' AND content ? 'type' THEN
      content->>'type' IN ('exit', 'employee')
    ELSE true
  END
);

-- Create function to get exit interviews for a company
CREATE OR REPLACE FUNCTION get_company_exit_interviews(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  title text,
  content jsonb,
  status text,
  issued_date timestamptz,
  staff_name text,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.staff_id,
    l.title,
    l.content,
    l.status::text,
    l.issued_date,
    s.name as staff_name,
    d.name as department_name
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'interview'
  AND l.content->>'type' = 'exit'
  AND s.company_id = p_company_id
  ORDER BY l.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to assign exit interview
CREATE OR REPLACE FUNCTION assign_exit_interview(
  p_staff_id uuid,
  p_title text DEFAULT 'Exit Interview Form'
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
BEGIN
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status,
    issued_date
  ) VALUES (
    p_staff_id,
    p_title,
    'interview',
    jsonb_build_object(
      'type', 'exit',
      'status', 'pending'
    ),
    'pending',
    now()
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;