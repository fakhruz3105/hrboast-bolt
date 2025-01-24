-- Drop existing function if it exists
DROP FUNCTION IF EXISTS initialize_company_benefits;

-- Create improved function to initialize company benefits
CREATE OR REPLACE FUNCTION initialize_company_benefits(p_company_id uuid)
RETURNS void AS $$
BEGIN
  -- Insert default benefits
  INSERT INTO benefits (
    company_id,
    name,
    description,
    amount,
    status,
    frequency
  ) VALUES
    (p_company_id, 'Medical Insurance', 'Annual medical coverage including hospitalization and outpatient care', 5000.00, true, 'Annual coverage'),
    (p_company_id, 'Dental Coverage', 'Annual dental care coverage including routine checkups', 1000.00, true, 'Annual coverage'),
    (p_company_id, 'Professional Development', 'Annual allowance for courses and certifications', 2000.00, true, 'Annual coverage'),
    (p_company_id, 'Gym Membership', 'Monthly gym membership reimbursement', 100.00, true, 'Monthly'),
    (p_company_id, 'Work From Home Setup', 'One-time allowance for home office setup', 1500.00, true, 'Once per employment'),
    (p_company_id, 'Transportation', 'Monthly transportation allowance', 200.00, true, 'Monthly'),
    (p_company_id, 'Wellness Program', 'Annual wellness program including health screenings', 800.00, true, 'Annual coverage'),
    (p_company_id, 'Education Subsidy', 'Support for continuing education', 5000.00, true, 'Annual coverage'),
    (p_company_id, 'Parental Leave', 'Paid parental leave benefit', 3000.00, true, 'Per child'),
    (p_company_id, 'Marriage Allowance', 'One-time marriage celebration allowance', 1000.00, true, 'Once per employment');

  -- Assign benefits to all staff levels
  INSERT INTO benefit_eligibility (benefit_id, level_id)
  SELECT b.id, sl.id
  FROM benefits b
  CROSS JOIN staff_levels sl
  WHERE b.company_id = p_company_id;
END;
$$ LANGUAGE plpgsql;

-- Initialize benefits for existing companies
DO $$
DECLARE
  v_company RECORD;
BEGIN
  FOR v_company IN SELECT id FROM companies LOOP
    -- Check if company already has benefits
    IF NOT EXISTS (
      SELECT 1 FROM benefits WHERE company_id = v_company.id
    ) THEN
      -- Initialize benefits for this company
      PERFORM initialize_company_benefits(v_company.id);
    END IF;
  END LOOP;
END $$;

-- Create function to get staff eligible benefits
CREATE OR REPLACE FUNCTION get_staff_eligible_benefits(staff_uid uuid)
RETURNS TABLE (
  id uuid,
  name text,
  description text,
  amount numeric,
  status boolean,
  frequency text,
  created_at timestamptz,
  updated_at timestamptz,
  is_eligible boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (b.id)
    b.id,
    b.name,
    b.description,
    b.amount,
    b.status,
    b.frequency,
    b.created_at,
    b.updated_at,
    EXISTS (
      SELECT 1 
      FROM benefit_eligibility be
      JOIN staff_levels_junction slj ON be.level_id = slj.level_id
      WHERE be.benefit_id = b.id 
      AND slj.staff_id = staff_uid
      AND slj.is_primary = true
    ) as is_eligible
  FROM benefits b
  WHERE b.status = true
  AND b.company_id = (
    SELECT company_id 
    FROM staff 
    WHERE id = staff_uid
  )
  ORDER BY b.id, b.created_at DESC;
END;
$$ LANGUAGE plpgsql;