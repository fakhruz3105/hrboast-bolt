/*
  # Warning Letters System Schema

  1. New Tables
    - `warning_letters`
      - `id` (uuid, primary key)
      - `staff_id` (uuid, references staff)
      - `warning_level` (enum: first, second, final)
      - `incident_date` (date)
      - `description` (text)
      - `improvement_plan` (text)
      - `consequences` (text)
      - `issued_date` (date)
      - `signed_document_url` (text, nullable)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for CRUD operations
*/

-- Create warning level enum
CREATE TYPE warning_level AS ENUM ('first', 'second', 'final');

-- Create warning letters table
CREATE TABLE warning_letters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE RESTRICT,
  warning_level warning_level NOT NULL,
  incident_date date NOT NULL,
  description text NOT NULL,
  improvement_plan text NOT NULL,
  consequences text NOT NULL,
  issued_date date NOT NULL,
  signed_document_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_dates CHECK (incident_date <= issued_date)
);

-- Create indexes
CREATE INDEX idx_warning_letters_staff_id ON warning_letters(staff_id);
CREATE INDEX idx_warning_letters_warning_level ON warning_letters(warning_level);
CREATE INDEX idx_warning_letters_issued_date ON warning_letters(issued_date);

-- Enable RLS
ALTER TABLE warning_letters ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users"
  ON warning_letters FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON warning_letters FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users"
  ON warning_letters FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create trigger for updated_at
CREATE TRIGGER set_warning_letters_updated_at
  BEFORE UPDATE ON warning_letters
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for signed documents
INSERT INTO storage.buckets (id, name)
VALUES ('warning-letters', 'warning-letters')
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
CREATE POLICY "Allow public read access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'warning-letters');

CREATE POLICY "Allow authenticated insert access"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'warning-letters'
    AND auth.role() = 'authenticated'
  );