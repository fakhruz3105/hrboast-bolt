-- Drop existing function
DROP FUNCTION IF EXISTS create_warning_letter;

-- Create improved function with proper enum handling
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
BEGIN
  -- Get company_id from staff
  SELECT company_id INTO v_company_id
  FROM staff
  WHERE id = p_staff_id;

  IF v_company_id IS NULL THEN
    RAISE EXCEPTION 'Staff member not found or has no company assigned';
  END IF;

  -- Insert warning letter with proper enum casting
  INSERT INTO warning_letters (
    staff_id,
    company_id,
    warning_level,
    incident_date,
    description,
    improvement_plan,
    consequences,
    issued_date
  ) VALUES (
    p_staff_id,
    v_company_id,
    CASE p_warning_level
      WHEN 'first' THEN 'first'::warning_level
      WHEN 'second' THEN 'second'::warning_level
      WHEN 'final' THEN 'final'::warning_level
      ELSE 'first'::warning_level -- Default to first if invalid
    END,
    p_incident_date,
    p_description,
    p_improvement_plan,
    p_consequences,
    p_issued_date
  ) RETURNING id INTO v_letter_id;

  RETURN v_letter_id;
END;
$$ LANGUAGE plpgsql;