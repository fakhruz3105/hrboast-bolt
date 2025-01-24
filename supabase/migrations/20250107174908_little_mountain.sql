-- Insert demo benefits
INSERT INTO benefits (name, description, amount, status)
VALUES
  ('Medical Insurance', 'Comprehensive medical coverage including hospitalization and outpatient care', 5000.00, true),
  ('Dental Coverage', 'Annual dental care coverage including routine checkups and procedures', 1000.00, true),
  ('Professional Development', 'Annual allowance for courses, certifications, and training programs', 2000.00, true),
  ('Gym Membership', 'Monthly gym membership reimbursement at partner facilities', 100.00, true),
  ('Work From Home Allowance', 'One-time allowance for home office setup', 1500.00, true),
  ('Transportation Allowance', 'Monthly allowance for commuting expenses', 200.00, true),
  ('Wellness Program', 'Annual wellness program including health screenings and fitness activities', 800.00, true),
  ('Education Subsidy', 'Support for continuing education and degree programs', 5000.00, true)
ON CONFLICT (id) DO NOTHING;

-- Set up benefit eligibility
WITH benefit_levels AS (
  SELECT 
    b.id as benefit_id,
    sl.id as level_id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE 
    -- Medical Insurance for all levels
    (b.name = 'Medical Insurance') OR
    -- Dental Coverage for all permanent staff
    (b.name = 'Dental Coverage' AND sl.name IN ('Director', 'C-Suite', 'HOD/Manager', 'HR', 'Staff')) OR
    -- Professional Development for management and above
    (b.name = 'Professional Development' AND sl.name IN ('Director', 'C-Suite', 'HOD/Manager')) OR
    -- Gym Membership for all permanent staff
    (b.name = 'Gym Membership' AND sl.name IN ('Director', 'C-Suite', 'HOD/Manager', 'HR', 'Staff')) OR
    -- Work From Home Allowance for all permanent staff
    (b.name = 'Work From Home Allowance' AND sl.name IN ('Director', 'C-Suite', 'HOD/Manager', 'HR', 'Staff')) OR
    -- Transportation Allowance for staff and HR
    (b.name = 'Transportation Allowance' AND sl.name IN ('Staff', 'HR')) OR
    -- Wellness Program for all levels
    (b.name = 'Wellness Program') OR
    -- Education Subsidy for management and above
    (b.name = 'Education Subsidy' AND sl.name IN ('Director', 'C-Suite', 'HOD/Manager'))
)
INSERT INTO benefit_eligibility (benefit_id, level_id)
SELECT benefit_id, level_id FROM benefit_levels
ON CONFLICT (benefit_id, level_id) DO NOTHING;

-- Drop existing function and recreate with fixed parameter names
DROP FUNCTION IF EXISTS check_benefit_eligibility;
CREATE OR REPLACE FUNCTION check_benefit_eligibility(p_staff_id uuid, p_benefit_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM staff s
    JOIN benefit_eligibility be ON s.level_id = be.level_id
    WHERE s.id = p_staff_id
    AND be.benefit_id = p_benefit_id
  );
END;
$$ LANGUAGE plpgsql;

-- Insert some sample claims
INSERT INTO benefit_claims (
  benefit_id,
  staff_id,
  amount,
  status,
  claim_date,
  notes
)
SELECT 
  b.id as benefit_id,
  s.id as staff_id,
  b.amount as amount,
  'pending' as status,
  CURRENT_DATE as claim_date,
  'Initial claim submission' as notes
FROM benefits b
CROSS JOIN staff s
WHERE b.name IN ('Medical Insurance', 'Dental Coverage')
  AND s.email = 'staff@example.com'
LIMIT 2;