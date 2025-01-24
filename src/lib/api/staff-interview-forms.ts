import { supabase } from '../supabase';
import { StaffInterviewForm } from '../../types/staffInterview';

export async function fetchStaffInterviewForms(): Promise<StaffInterviewForm[]> {
  const { data, error } = await supabase
    .from('staff_interview_forms')
    .select(`
      *,
      interview:staff_interviews (
        staff_name,
        email,
        department:departments(name),
        level:staff_levels(name)
      )
    `)
    .order('submitted_at', { ascending: false });
    
  if (error) throw new Error(`Failed to fetch interview forms: ${error.message}`);
  return data;
}

export async function getStaffInterviewForm(id: string): Promise<StaffInterviewForm> {
  const { data, error } = await supabase
    .from('staff_interview_forms')
    .select(`
      *,
      interview:staff_interviews (
        staff_name,
        email,
        department:departments(name),
        level:staff_levels(name)
      )
    `)
    .eq('id', id)
    .single();
    
  if (error) throw new Error(`Failed to fetch interview form: ${error.message}`);
  return data;
}