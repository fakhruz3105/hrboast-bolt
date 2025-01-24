-- Create benefits table
CREATE TABLE IF NOT EXISTS benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  amount numeric(10,2) NOT NULL,
  status boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create benefit claims table
CREATE TABLE IF NOT EXISTS benefit_claims (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  benefit_id uuid REFERENCES benefits(id) ON DELETE CASCADE,
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  amount numeric(10,2) NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  claim_date date NOT NULL DEFAULT CURRENT_DATE,
  receipt_url text,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE benefits ENABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_claims ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "benefits_select" ON benefits FOR SELECT USING (true);
CREATE POLICY "benefit_claims_select" ON benefit_claims FOR SELECT USING (true);