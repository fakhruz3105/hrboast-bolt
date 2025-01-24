-- First drop any dependent objects
DO $$ 
BEGIN
  -- Drop policies that might reference the type
  DROP POLICY IF EXISTS "hr_letters_select" ON hr_letters;
  DROP POLICY IF EXISTS "hr_letters_insert" ON hr_letters;
  DROP POLICY IF EXISTS "hr_letters_update" ON hr_letters;
END $$;

-- Update the letter_type enum to include show_cause
ALTER TYPE letter_type ADD VALUE IF NOT EXISTS 'show_cause';

-- Recreate policies
CREATE POLICY "hr_letters_select"
  ON hr_letters FOR SELECT
  USING (true);

CREATE POLICY "hr_letters_insert"
  ON hr_letters FOR INSERT
  WITH CHECK (true);

CREATE POLICY "hr_letters_update"
  ON hr_letters FOR UPDATE
  USING (true);

-- Create type for show cause reasons if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'show_cause_type') THEN
    CREATE TYPE show_cause_type AS ENUM (
      'lateness',
      'harassment',
      'leave_without_approval',
      'offensive_behavior',
      'insubordination',
      'misconduct'
    );
  END IF;
END $$;

-- Update create_show_cause_letter function to handle the type properly
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