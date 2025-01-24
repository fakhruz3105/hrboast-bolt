import { supabase } from '../supabase';
import { StaffLevel, StaffLevelFormData } from '../../types/staffLevel';

export async function fetchStaffLevels(): Promise<StaffLevel[]> {
  const { data, error } = await supabase
    .from('staff_levels')
    .select('*')
    .order('rank');
    
  if (error) throw error;
  return data;
}

export async function insertStaffLevel(level: StaffLevelFormData): Promise<StaffLevel> {
  const { data, error } = await supabase
    .from('staff_levels')
    .insert([level])
    .select()
    .single();
    
  if (error) throw error;
  return data;
}

export async function updateStaffLevel(id: string, level: Partial<StaffLevelFormData>): Promise<StaffLevel> {
  const { data, error } = await supabase
    .from('staff_levels')
    .update({ ...level, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();
    
  if (error) throw error;
  return data;
}

export async function deleteStaffLevel(id: string): Promise<void> {
  const { error } = await supabase
    .from('staff_levels')
    .delete()
    .eq('id', id);
    
  if (error) throw error;
}