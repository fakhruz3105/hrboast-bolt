export type StaffStatus = 'permanent' | 'probation' | 'resigned';

export type StaffDepartment = {
  id: string;
  staff_id: string;
  department_id: string;
  is_primary: boolean;
  department?: {
    id: string;
    name: string;
  };
};

export type StaffLevelJunction = {
  id: string;
  staff_id: string;
  level_id: string;
  is_primary: boolean;
  level?: {
    id: string;
    name: string;
    rank: number;
  };
};

export type Staff = {
  id: string;
  name: string;
  phone_number: string;
  email: string;
  role_id: string;
  join_date: string;
  status: StaffStatus;
  company_id: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
  departments?: StaffDepartment[];
  levels?: StaffLevelJunction[];
  role?: {
    id: string;
    role: string;
  };
  company?: {
    id: string;
    name: string;
    email: string;
  };
};

export type StaffFormData = Omit<Staff, 'id' | 'created_at' | 'updated_at' | 'departments' | 'levels' | 'role' | 'role_id' | 'company_id' | 'is_active' | 'company'> & {
  department_ids: string[];
  primary_department_id: string;
  level_ids: string[];
  primary_level_id: string;
};