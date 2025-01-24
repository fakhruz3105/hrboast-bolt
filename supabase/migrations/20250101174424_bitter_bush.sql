/*
  # Fix Staff Interview System

  1. Changes
    - Simplify triggers to prevent stack depth issues
    - Add missing indexes for performance
    - Update RLS policies
*/

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS check_expired_interviews ON staff_interviews;
DROP FUNCTION IF EXISTS update_expired_interviews();

-- Recreate trigger function with simplified logic
CREATE OR REPLACE FUNCTION update_expired_interviews()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'pending' AND NEW.expires_at < NOW() THEN
    NEW.status = 'expired';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger that runs before insert or update
CREATE TRIGGER check_expired_interviews
  BEFORE INSERT OR UPDATE ON staff_interviews
  FOR EACH ROW
  EXECUTE FUNCTION update_expired_interviews();

-- Add composite index for status and expires_at
CREATE INDEX IF NOT EXISTS idx_staff_interviews_status_expires 
ON staff_interviews(status, expires_at);

-- Update RLS policies with better performance
DROP POLICY IF EXISTS "Enable read access for all users on staff_interviews" ON staff_interviews;
CREATE POLICY "Enable read access for all users on staff_interviews"
  ON staff_interviews FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Enable insert access for all users on staff_interviews" ON staff_interviews;
CREATE POLICY "Enable insert access for all users on staff_interviews"
  ON staff_interviews FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Enable update access for all users on staff_interviews" ON staff_interviews;
CREATE POLICY "Enable update access for all users on staff_interviews"
  ON staff_interviews FOR UPDATE
  USING (true)
  WITH CHECK (true);