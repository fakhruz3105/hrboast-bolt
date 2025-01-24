-- Add created_at and updated_at columns to hr_letters if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'hr_letters' AND column_name = 'created_at'
  ) THEN
    ALTER TABLE hr_letters 
    ADD COLUMN created_at timestamptz DEFAULT now();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'hr_letters' AND column_name = 'updated_at'
  ) THEN
    ALTER TABLE hr_letters 
    ADD COLUMN updated_at timestamptz DEFAULT now();
  END IF;
END $$;

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_hr_letters_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_hr_letters_timestamp
  BEFORE UPDATE ON hr_letters
  FOR EACH ROW
  EXECUTE FUNCTION update_hr_letters_updated_at();