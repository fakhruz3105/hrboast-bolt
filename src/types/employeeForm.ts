export type EmployeeFormRequest = {
  id: string;
  staff_name: string;
  email: string;
  phone_number: string;
  department_id: string;
  level_id: string;
  form_link: string;
  status: 'pending' | 'completed';
  created_at: string;
  expires_at: string;
};

export type EmployeeFormResponse = {
  id: string;
  request_id: string;
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
  employment_history: Array<{
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
};