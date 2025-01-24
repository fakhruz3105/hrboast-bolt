export type StaffInterviewStatus = 'pending' | 'completed' | 'expired';

export type StaffInterview = {
  id: string;
  staff_name: string;
  email: string;
  department_id: string;
  level_id: string;
  form_link: string;
  status: StaffInterviewStatus;
  created_at: string;
  expires_at: string;
  department?: {
    name: string;
  };
  level?: {
    name: string;
  };
};

export type StaffInterviewFormData = {
  staff_name: string;
  email: string;
  department_id: string;
  level_id: string;
};

export type StaffInterviewForm = {
  id: string;
  interview_id: string;
  personal_info: {
    fullName: string;
    nricPassport: string;
    dateOfBirth: string;
    gender: string;
    nationality: string;
    address: string;
    phone: string;
    email: string;
  };
  education_history: Array<{
    institution: string;
    qualification: string;
    fieldOfStudy: string;
    graduationYear: string;
  }>;
  work_experience: Array<{
    company: string;
    position: string;
    startDate: string;
    endDate: string;
    responsibilities: string;
  }>;
  emergency_contacts: Array<{
    name: string;
    relationship: string;
    phone: string;
    address: string;
  }>;
  submitted_at: string;
  interview?: {
    staff_name: string;
    email: string;
    department: {
      name: string;
    };
    level: {
      name: string;
    };
  };
};