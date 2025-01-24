import { Database as DatabaseGenerated } from './supabase-types';

export type Database = DatabaseGenerated;

export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row'];
export type Enums<T extends keyof Database['public']['Enums']> = Database['public']['Enums'][T];

export type StaffLevel = Tables<'staff_levels'>;
export type StaffLevelInsert = Database['public']['Tables']['staff_levels']['Insert'];
export type StaffLevelUpdate = Database['public']['Tables']['staff_levels']['Update'];