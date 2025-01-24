-- Drop existing policies
DROP POLICY IF EXISTS "hr_letters_select" ON hr_letters;
DROP POLICY IF EXISTS "hr_letters_insert" ON hr_letters;
DROP POLICY IF EXISTS "hr_letters_update" ON hr_letters;

-- Create simpler RLS policies
CREATE POLICY "hr_letters_select"
  ON hr_letters FOR SELECT
  USING (true);  -- Allow all authenticated users to view letters

CREATE POLICY "hr_letters_insert"
  ON hr_letters FOR INSERT
  WITH CHECK (true);  -- Allow all authenticated users to create letters

CREATE POLICY "hr_letters_update"
  ON hr_letters FOR UPDATE
  USING (true);  -- Allow all authenticated users to update letters

-- Add trigger for warning letters to create HR letter
CREATE OR REPLACE FUNCTION create_hr_letter_for_warning()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO hr_letters (
    staff_id,
    title,
    type,
    content,
    issued_date,
    status
  ) VALUES (
    NEW.staff_id,
    'Warning Letter - ' || UPPER(NEW.warning_level),
    'warning',
    jsonb_build_object(
      'warning_letter_id', NEW.id,
      'warning_level', NEW.warning_level,
      'incident_date', NEW.incident_date,
      'description', NEW.description,
      'improvement_plan', NEW.improvement_plan,
      'consequences', NEW.consequences
    ),
    NEW.issued_date,
    CASE 
      WHEN NEW.signed_document_url IS NOT NULL THEN 'signed'::letter_status
      ELSE 'pending'::letter_status
    END
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS warning_letter_hr_letter ON warning_letters;
CREATE TRIGGER warning_letter_hr_letter
  AFTER INSERT ON warning_letters
  FOR EACH ROW
  EXECUTE FUNCTION create_hr_letter_for_warning();

-- Update trigger for when warning letter is signed
CREATE OR REPLACE FUNCTION update_hr_letter_status()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.signed_document_url IS NOT NULL AND OLD.signed_document_url IS NULL THEN
    UPDATE hr_letters
    SET 
      status = 'signed',
      document_url = NEW.signed_document_url
    WHERE 
      type = 'warning' 
      AND content->>'warning_letter_id' = NEW.id::text;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for status updates
DROP TRIGGER IF EXISTS warning_letter_status_update ON warning_letters;
CREATE TRIGGER warning_letter_status_update
  AFTER UPDATE ON warning_letters
  FOR EACH ROW
  EXECUTE FUNCTION update_hr_letter_status();