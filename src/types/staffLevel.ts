export type StaffLevel = {
  id: string;
  name: string;
  description: string;
  rank: number;
  created_at?: string;
  updated_at?: string;
};

export type StaffLevelFormData = Omit<StaffLevel, 'id' | 'created_at' | 'updated_at'>;