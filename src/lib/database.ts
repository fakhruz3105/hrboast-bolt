import { supabase } from './supabase';
import { StaffLevel, StaffLevelFormData } from '../types/staffLevel';

export async function fetchStaffLevels() {
  const { data, error } = await supabase
    .from('staff_levels')
    .select('*')
    .order('rank');
    
  if (error) throw error;
  return data;
}

export async function insertStaffLevels(levels: StaffLevelFormData[]) {
  const { data, error } = await supabase
    .from('staff_levels')
    .insert(levels)
    .select();
    
  if (error) throw error;
  return data;
}

export async function updateStaffLevel(id: string, level: StaffLevelFormData) {
  const { data, error } = await supabase
    .from('staff_levels')
    .update(level)
    .eq('id', id)
    .select()
    .single();
    
  if (error) throw error;
  return data;
}

export async function deleteStaffLevel(id: string) {
  const { error } = await supabase
    .from('staff_levels')
    .delete()
    .eq('id', id);
    
  if (error) throw error;
}