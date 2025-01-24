export type Department = {
  id: string;
  name: string;
  description: string | null;
  created_at?: string;
  updated_at?: string;
};

export type DepartmentFormData = Omit<Department, 'id' | 'created_at' | 'updated_at'>;