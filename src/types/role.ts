export type Role = 'admin' | 'hr' | 'staff';

export type RoleMapping = {
  id: string;
  staff_level_id: string;
  role: Role;
  created_at?: string;
  updated_at?: string;
  staff_level?: {
    name: string;
  };
};

export type RoleMappingFormData = Omit<RoleMapping, 'id' | 'created_at' | 'updated_at' | 'staff_level'>;