-- Create function to create show cause letter
CREATE OR REPLACE FUNCTION create_show_cause_letter(
  p_staff_id uuid,
  p_type show_cause_type,
  p_title text,
  p_incident_date date,
  p_description text
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
BEGIN
  -- Create HR letter record
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    status
  ) VALUES (
    p_staff_id,
    CASE 
      WHEN p_type = 'misconduct' THEN p_title
      ELSE initcap(replace(p_type::text, '_', ' '))
    END,
    'show_cause',
    jsonb_build_object(
      'type', p_type,
      'title', p_title,
      'incident_date', p_incident_date,
      'description', p_description,
      'status', 'pending'
    ),
    'pending'
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;

-- Create function to submit show cause response
CREATE OR REPLACE FUNCTION submit_show_cause_response(
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
  AND type = 'show_cause'
  AND status = 'pending';
END;
$$ LANGUAGE plpgsql;