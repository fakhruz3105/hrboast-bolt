import { useState, useEffect } from 'react';
import { Department, DepartmentFormData } from '../types/department';
import { useSupabase } from '../providers/SupabaseProvider';

export function useDepartments() {
  const supabase = useSupabase();
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadDepartments() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('departments')
        .select('*')
        .order('name');
        
      if (error) throw new Error(`Failed to fetch departments: ${error.message}`);
      setDepartments(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load departments'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadDepartments();
  }, []);

  async function addDepartment(department: DepartmentFormData) {
    try {
      const { data, error } = await supabase
        .from('departments')
        .insert([department])
        .select()
        .single();
        
      if (error) throw new Error(`Failed to create department: ${error.message}`);
      setDepartments(prev => [...prev, data]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to add department');
    }
  }

  async function updateDepartment(id: string, updates: Partial<DepartmentFormData>) {
    try {
      const { data, error } = await supabase
        .from('departments')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
        
      if (error) throw new Error(`Failed to update department: ${error.message}`);
      setDepartments(prev => prev.map(dept => dept.id === id ? data : dept));
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to update department');
    }
  }

  async function deleteDepartment(id: string) {
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
      setDepartments(prev => prev.filter(dept => dept.id !== id));
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to delete department');
    }
  }

  return {
    departments,
    loading,
    error,
    addDepartment,
    updateDepartment,
    deleteDepartment,
    refresh: loadDepartments
  };
}