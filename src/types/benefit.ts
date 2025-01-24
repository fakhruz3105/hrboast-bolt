export type Benefit = {
  id: string;
  company_id: string;
  name: string;
  description: string | null;
  amount: number;
  status: boolean;
  frequency: string;
  created_at?: string;
  updated_at?: string;
};

export type BenefitFormData = Omit<Benefit, 'id' | 'created_at' | 'updated_at' | 'company_id'>;

export type BenefitClaim = {
  id: string;
  benefit_id: string;
  staff_id: string;
  amount: number;
  status: 'pending' | 'approved' | 'rejected';
  claim_date: string;
  receipt_url?: string;
  notes?: string;
  created_at?: string;
  updated_at?: string;
  benefit?: Benefit;
  staff?: {
    name: string;
    department?: {
      name: string;
    };
  };
};