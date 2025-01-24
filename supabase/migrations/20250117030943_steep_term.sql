-- Create company events table
CREATE TABLE company_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id uuid REFERENCES companies(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  quarter text NOT NULL CHECK (quarter IN ('Q1', 'Q2', 'Q3', 'Q4')),
  start_date date NOT NULL,
  end_date date NOT NULL,
  status text NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_dates CHECK (start_date <= end_date)
);

-- Create indexes
CREATE INDEX idx_company_events_company ON company_events(company_id);
CREATE INDEX idx_company_events_quarter ON company_events(quarter);
CREATE INDEX idx_company_events_dates ON company_events(start_date, end_date);
CREATE INDEX idx_company_events_status ON company_events(status);

-- Enable RLS
ALTER TABLE company_events ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "company_events_select"
  ON company_events FOR SELECT
  USING (true);

CREATE POLICY "company_events_insert"
  ON company_events FOR INSERT
  WITH CHECK (true);

CREATE POLICY "company_events_update"
  ON company_events FOR UPDATE
  USING (true);

CREATE POLICY "company_events_delete"
  ON company_events FOR DELETE
  USING (true);

-- Create trigger for updated_at
CREATE TRIGGER set_company_events_timestamp
  BEFORE UPDATE ON company_events
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create function to update event status
CREATE OR REPLACE FUNCTION update_event_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Update status based on dates
  IF NEW.start_date > CURRENT_DATE THEN
    NEW.status := 'upcoming';
  ELSIF NEW.end_date < CURRENT_DATE THEN
    NEW.status := 'completed';
  ELSE
    NEW.status := 'ongoing';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for status updates
CREATE TRIGGER update_event_status_trigger
  BEFORE INSERT OR UPDATE ON company_events
  FOR EACH ROW
  EXECUTE FUNCTION update_event_status();