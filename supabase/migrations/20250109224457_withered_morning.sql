-- Insert sample benefits
INSERT INTO benefits (name, description, amount, status, frequency)
VALUES
  ('Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'yearly'),
  ('Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'yearly'),
  ('Transportation Allowance', 'Monthly transportation reimbursement', 200.00, true, 'monthly'),
  ('Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'monthly'),
  ('Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'yearly')
ON CONFLICT DO NOTHING;

-- Assign benefits to staff level
INSERT INTO benefit_eligibility (benefit_id, level_id)
SELECT b.id, sl.id
FROM benefits b
CROSS JOIN staff_levels sl
WHERE sl.name = 'Staff'
  AND b.name IN (
    'Medical Insurance',
    'Dental Coverage',
    'Transportation Allowance',
    'Gym Membership'
  )
ON CONFLICT DO NOTHING;