export type KPIStatus = 'Pending' | 'Achieved' | 'Not Achieved';

export type KPIType = {
  id: string;
  title: string;
  description: string;
  period: string;
  start_date: string;
  end_date: string;
  department_id?: string | null;
  staff_id?: string | null;
  status: KPIStatus;
  admin_comment?: string;
  created_at: string;
  updated_at: string;
  department?: {
    id: string;
    name: string;
  } | null;
  staff?: {
    id: string;
    name: string;
  } | null;
  feedback?: Array<{
    id: string;
    message: string;
    created_at: string;
    created_by: string;
    is_admin: boolean;
  }>;
};