export type MemoType = 'recognition' | 'rewards' | 'bonus' | 'salary_increment';

export type Memo = {
  id: string;
  title: string;
  type: MemoType;
  content: string;
  department_id: string | null;
  staff_id: string | null;
  company_id: string;
  created_at: string;
  updated_at: string;
  department_name?: string;
  staff_name?: string;
};

export type MemoFormData = Omit<Memo, 'id' | 'created_at' | 'updated_at'>;