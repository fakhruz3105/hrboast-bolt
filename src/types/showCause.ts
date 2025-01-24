export type ShowCauseType = 
  | 'lateness'
  | 'harassment'
  | 'leave_without_approval'
  | 'offensive_behavior'
  | 'insubordination'
  | 'misconduct';

export type ShowCauseLetter = {
  id: string;
  staff_id: string;
  type: ShowCauseType;
  title: string;
  incident_date: string;
  description: string;
  issued_date: string;
  response?: string;
  response_date?: string;
  status: 'pending' | 'responded';
  staff?: {
    name: string;
    department?: {
      name: string;
    };
  };
};

export type ShowCauseFormData = Omit<ShowCauseLetter, 'id' | 'issued_date' | 'status' | 'staff'>;