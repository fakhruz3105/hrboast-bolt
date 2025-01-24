export type WarningLevel = 'first' | 'second' | 'final';

export type WarningLetter = {
  id: string;
  staff_id: string;
  warning_level: WarningLevel;
  incident_date: string;
  description: string;
  improvement_plan: string;
  consequences: string;
  issued_date: string;
  show_cause_response?: string;
  response_submitted_at?: string;
  staff?: {
    name: string;
    departments?: Array<{
      is_primary: boolean;
      department: {
        name: string;
      };
    }>;
  };
};

export type WarningLetterFormData = Omit<WarningLetter, 'id' | 'staff' | 'show_cause_response' | 'response_submitted_at'>;