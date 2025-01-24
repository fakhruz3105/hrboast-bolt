import { supabase } from '../supabase';
import { Department, DepartmentFormData } from '../../types/department';
import { handleError } from '../utils/errorHandler';

export async function fetchDepartments(): Promise<Department[]> {
  const { data, error } = await supabase
    .from('departments')
    .select('*')
    .order('name');
    
  if (error) throw new Error(`Failed to fetch departments: ${error.message}`);
  return data;
}

export async function createDepartment(department: DepartmentFormData): Promise<Department> {
  const { data, error } = await supabase
    .from('departments')
    .insert([department])
    .select()
    .single();
    
  if (error) throw new Error(`Failed to create department: ${error.message}`);
  return data;
}

export async function updateDepartment(id: string, updates: Partial<DepartmentFormData>): Promise<Department> {
  const { data, error } = await supabase
    .from('departments')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
    
  if (error) throw new Error(`Failed to update department: ${error.message}`);
  return data;
}

export async function deleteDepartment(id: string): Promise<void> {
  try {
    const { error } = await supabase
      .rpc('delete_department', { p_department_id: id });
      
    if (error) {
      // Check for specific error about staff members
      if (error.message.includes('has staff members')) {
        throw new Error('Cannot delete department that has staff members assigned to it');
      }
      throw new Error(`Failed to delete department: ${error.message}`);
    }
  } catch (error) {
    handleError(error);
    throw error; // Re-throw to be handled by the component
  }
}