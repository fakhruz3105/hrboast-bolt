-- Drop existing constraint
ALTER TABLE warning_letters
DROP CONSTRAINT IF EXISTS valid_dates;

-- Add new constraint that ensures incident_date is not in the future
ALTER TABLE warning_letters
ADD CONSTRAINT valid_incident_date 
CHECK (incident_date <= CURRENT_DATE);

-- Add new constraint that ensures issued_date is not in the future
ALTER TABLE warning_letters
ADD CONSTRAINT valid_issued_date 
CHECK (issued_date <= CURRENT_DATE);

-- Add new constraint that ensures issued_date is not before incident_date
ALTER TABLE warning_letters
ADD CONSTRAINT issued_after_incident 
CHECK (issued_date >= incident_date);