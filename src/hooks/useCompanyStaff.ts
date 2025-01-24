import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Staff } from '../types/staff';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useCompanyStaff() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [staff, setStaff] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (user?.id) {
      loadStaff();
    }
  }, [user?.id]);

  const loadStaff = async () => {
    try {
      setLoading(true);

      const { data, error } = await supabase
        .from('staff')
        .select(`
          *,
          departments:staff_departments(
            id,
            department_id,
            is_primary,
            department:departments(
              id,
              name
            )
          ),
          levels:staff_levels_junction(
            id,
            level_id,
            is_primary,
            level:staff_levels(
              id,
              name,
              rank
            )
          ),
          role:role_id(
            id,
            role
          )
        `)
        .order('name');

      if (error) throw error;
      setStaff(data || []);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load staff');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  const addStaff = async (staffData: Partial<Staff>) => {
    try {
      const { data, error } = await supabase
        .from('staff')
        .insert([staffData])
        .select()
        .single();

      if (error) throw error;
      setStaff(prev => [...prev, data]);
      return data;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to add staff');
      toast.error(error.message);
      throw error;
    }
  };

  const updateStaff = async (id: string, updates: Partial<Staff>) => {
    try {
      const { data, error } = await supabase
        .from('staff')
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      setStaff(prev => prev.map(s => s.id === id ? data : s));
      return data;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update staff');
      toast.error(error.message);
      throw error;
    }
  };

  const deleteStaff = async (id: string) => {
    try {
      const { error } = await supabase
        .from('staff')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setStaff(prev => prev.filter(s => s.id !== id));
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to delete staff');
      toast.error(error.message);
      throw error;
    }
  };

  return {
    staff,
    loading,
    error,
    addStaff,
    updateStaff,
    deleteStaff,
    refresh: loadStaff
  };
}