import { supabase } from '../supabase';
import { StaffLevel, StaffLevelFormData } from '../../types/staffLevel';

export async function fetchStaffLevels(): Promise<StaffLevel[]> {
  const { data, error } = await supabase
    .from('staff_levels')
    .select('*')
    .order('rank');
    
  if (error) throw new Error(`Failed to fetch staff levels: ${error.message}`);
  return data;
}

export async function createStaffLevel(level: StaffLevelFormData): Promise<StaffLevel> {
  const { data, error } = await supabase
    .from('staff_levels')
    .insert([level])
    .select()
    .single();
    
  if (error) throw new Error(`Failed to create staff level: ${error.message}`);
  return data;
}

export async function updateStaffLevel(id: string, updates: Partial<StaffLevelFormData>): Promise<StaffLevel> {
  const { data, error } = await supabase
    .from('staff_levels')
    .update({ ...updates, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single();
    
  if (error) throw new Error(`Failed to update staff level: ${error.message}`);
  return data;
}

export async function deleteStaffLevel(id: string): Promise<void> {
  const { error } = await supabase
    .from('staff_levels')
    .delete()
    .eq('id', id);
    
  if (error) throw new Error(`Failed to delete staff level: ${error.message}`);
}