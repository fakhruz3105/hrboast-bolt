import { useState, useEffect } from 'react';
import { Department, DepartmentFormData } from '../types/department';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useDepartments() {
  const supabase = useSupabase();
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const loadDepartments = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('departments')
        .select('*')
        .order('name');
        
      if (error) throw error;
      setDepartments(data || []);
      setError(null);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load departments');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDepartments();
  }, []);

  const addDepartment = async (department: DepartmentFormData) => {
    try {
      const { data, error } = await supabase
        .from('departments')
        .insert([department])
        .select()
        .single();
        
      if (error) {
        if (error.code === '23505') { // Unique violation
          throw new Error('A department with this name already exists');
        }
        throw error;
      }

      setDepartments(prev => [...prev, data]);
      setError(null);
      return data;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to add department');
      setError(error);
      throw error;
    }
  };

  const updateDepartment = async (id: string, updates: Partial<DepartmentFormData>) => {
    try {
      const { data, error } = await supabase
        .from('departments')
        .update(updates)
        .eq('id', id)
        .select()
        .single();
        
      if (error) {
        if (error.code === '23505') { // Unique violation
          throw new Error('A department with this name already exists');
        }
        throw error;
      }

      setDepartments(prev => prev.map(dept => dept.id === id ? data : dept));
      setError(null);
      return data;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update department');
      setError(error);
      throw error;
    }
  };

  const deleteDepartment = async (id: string) => {
    try {
      const { error } = await supabase.rpc('delete_department', {
        p_department_id: id
      });
        
      if (error) {
        // Check for specific error about staff members
        if (error.message.includes('has staff members')) {
          throw new Error('Cannot delete department that has staff members assigned to it');
        }
        throw error;
      }

      setDepartments(prev => prev.filter(dept => dept.id !== id));
      setError(null);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to delete department');
      setError(error);
      throw error;
    }
  };

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