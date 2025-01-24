import { supabase } from '../supabase';
import { StaffInterview, StaffInterviewFormData } from '../../types/staffInterview';

export async function fetchStaffInterviews(): Promise<StaffInterview[]> {
  const { data, error } = await supabase
    .from('staff_interviews')
    .select(`
      *,
      department:departments(name),
      level:staff_levels(name)
    `)
    .order('created_at', { ascending: false });
    
  if (error) throw new Error(`Failed to fetch staff interviews: ${error.message}`);
  return data;
}

export async function createStaffInterview(interview: StaffInterviewFormData): Promise<StaffInterview> {
  const formId = crypto.randomUUID();
  const formLink = `/staff-form/${formId}`;
  
  const { data, error } = await supabase
    .from('staff_interviews')
    .insert([{
      ...interview,
      id: formId,
      form_link: formLink,
      status: 'pending',
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
    }])
    .select(`
      *,
      department:departments(name),
      level:staff_levels(name)
    `)
    .single();
    
  if (error) throw new Error(`Failed to create staff interview: ${error.message}`);
  return data;
}

export async function updateStaffInterview(id: string, updates: Partial<StaffInterviewFormData>): Promise<StaffInterview> {
  const { data, error } = await supabase
    .from('staff_interviews')
    .update(updates)
    .eq('id', id)
    .select(`
      *,
      department:departments(name),
      level:staff_levels(name)
    `)
    .single();
    
  if (error) throw new Error(`Failed to update staff interview: ${error.message}`);
  return data;
}

export async function deleteStaffInterview(id: string): Promise<void> {
  const { error } = await supabase
    .from('staff_interviews')
    .delete()
    .eq('id', id);
    
  if (error) throw new Error(`Failed to delete staff interview: ${error.message}`);
}