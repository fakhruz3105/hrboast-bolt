-- Add show cause response columns to warning_letters table
ALTER TABLE warning_letters
ADD COLUMN show_cause_response text,
ADD COLUMN response_submitted_at timestamptz;

-- Create index for response date
CREATE INDEX idx_warning_letters_response_date 
ON warning_letters(response_submitted_at);