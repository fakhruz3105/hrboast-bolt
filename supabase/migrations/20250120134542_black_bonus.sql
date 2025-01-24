-- Drop existing function if it exists
DROP FUNCTION IF EXISTS create_warning_letter;

-- Create improved function with proper warning level handling
CREATE OR REPLACE FUNCTION create_warning_letter(
  p_staff_id uuid,
  p_warning_level text, -- Change to text to allow easier input
  p_incident_date date,
  p_description text,
  p_improvement_plan text,
  p_consequences text,
  p_issued_date date
)
RETURNS uuid AS $$
DECLARE
  v_letter_id uuid;
BEGIN
  -- Insert warning letter with proper casting
  INSERT INTO warning_letters (
    staff_id,
    warning_level,
    incident_date,
    description,
    improvement_plan,
    consequences,
    issued_date
  ) VALUES (
    p_staff_id,
    p_warning_level::warning_level,  -- Cast text to warning_level enum
    p_incident_date,
    p_description,
    p_improvement_plan,
    p_consequences,
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;