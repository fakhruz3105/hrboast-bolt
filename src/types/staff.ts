export type StaffStatus = 'permanent' | 'probation' | 'resigned';

export type Staff = {
  id: string;
  name: string;
  email: string;
  phone_number: string;
  join_date: string;
  status: StaffStatus;
  is_active: boolean;
  company_id: string;
  role_id: string;
  departments?: Array<{
    id: string;
    is_primary: boolean;
    department: {
      id: string;
      name: string;
    };
  }>;
  levels?: Array<{
    id: string;
    is_primary: boolean;
    level: {
      id: string;
      name: string;
      rank: number;
    };
  }>;
  role?: {
    id: string;
    role: string;
  };
};

export type StaffFormData = {
  name: string;
  phone_number: string;
  email: string;
  department_ids: string[];
  primary_department_id: string;
  level_ids: string[];
  primary_level_id: string;
  join_date: string;
  status: string;
  role_id: string;
}