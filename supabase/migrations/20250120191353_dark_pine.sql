-- Create warning level enum if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'warning_level') THEN
    CREATE TYPE warning_level AS ENUM ('first', 'second', 'final');
  END IF;
END $$;

-- Create function to create warning letter
CREATE OR REPLACE FUNCTION create_warning_letter(
  p_staff_id uuid,
  p_warning_level text,
  p_incident_date date,
  p_description text,
  p_improvement_plan text,
  p_consequences text,
  p_issued_date date
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
  v_company_id uuid;
  v_staff_name text;
BEGIN
  -- Get company_id and staff name
  SELECT company_id, name INTO v_company_id, v_staff_name
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  -- Create HR letter for warning
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status,
    issued_date
  ) VALUES (
    p_staff_id,
    initcap(p_warning_level) || ' Warning Letter - ' || v_staff_name,
    'warning',
    jsonb_build_object(
      'warning_level', p_warning_level,
      'incident_date', p_incident_date,
      'description', p_description,
      'improvement_plan', p_improvement_plan,
      'consequences', p_consequences,
      'status', 'pending'
    ),
    'pending',
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to get company warning letters
CREATE OR REPLACE FUNCTION get_company_warning_letters(p_company_id uuid)
RETURNS TABLE (
  id uuid,
  staff_id uuid,
  warning_level text,
  incident_date date,
  description text,
  improvement_plan text,
  consequences text,
  issued_date date,
  show_cause_response text,
  response_submitted_at timestamptz,
  staff_name text,
  department_name text
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    l.id,
    l.staff_id,
    l.content->>'warning_level',
    (l.content->>'incident_date')::date,
    l.content->>'description',
    l.content->>'improvement_plan',
    l.content->>'consequences',
    l.issued_date,
    l.content->>'response',
    (l.content->>'response_date')::timestamptz,
    s.name as staff_name,
    d.name as department_name
  FROM hr_letters l
  JOIN staff s ON l.staff_id = s.id
  LEFT JOIN staff_departments sd ON s.id = sd.staff_id AND sd.is_primary = true
  LEFT JOIN departments d ON sd.department_id = d.id
  WHERE l.type = 'warning'
  AND s.company_id = p_company_id
  ORDER BY l.issued_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Create function to submit warning letter response
CREATE OR REPLACE FUNCTION submit_warning_letter_response(
  p_letter_id uuid,
  p_response text
)
RETURNS void AS $$
BEGIN
  UPDATE hr_letters
  SET 
    content = jsonb_set(
      jsonb_set(
        content,
        '{response}',
        to_jsonb(p_response)
      ),
      '{response_date}',
      to_jsonb(now())
    ),
    status = 'submitted'
  WHERE id = p_letter_id
  AND type = 'warning'
  AND status = 'pending';
END;
$$ LANGUAGE plpgsql;