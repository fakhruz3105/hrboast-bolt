export type ExitInterview = {
  id: string;
  staff_id: string;
  reason: string;
  detailedReason: string;
  lastWorkingDate: string;
  suggestions?: string;
  handoverNotes: string;
  exitChecklist: {
    returnedLaptop: boolean;
    returnedAccessCard: boolean;
    completedHandover: boolean;
    clearedDues: boolean;
  };
  created_at?: string;
};

export type ExitInterviewFormData = Omit<ExitInterview, 'id' | 'created_at'>;