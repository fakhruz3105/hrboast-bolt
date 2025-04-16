import { useState, useEffect } from 'react';
import { StaffLevel, StaffLevelFormData } from '../types/staffLevel';
import { useSupabase } from '../providers/SupabaseProvider';

export function useStaffLevels() {
  const supabase = useSupabase();
  const [levels, setLevels] = useState<StaffLevel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadLevels() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('staff_levels')
        .select(`
          *,
          role_mappings (
            id
          )
        `)
        .order('rank');
        
      if (error) throw new Error(`Failed to fetch staff levels: ${error.message}`);
      setLevels(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load staff levels'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadLevels();
  }, []);

  async function addLevel(level: StaffLevelFormData) {
    try {
      const { data, error } = await supabase
        .from('staff_levels')
        .insert([level])
        .select()
        .single();
        
      if (error) throw new Error(`Failed to create staff level: ${error.message}`);

      setLevels(prev => [...prev, data]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to add staff level');
    }
  }

  async function updateLevel(id: string, updates: Partial<StaffLevelFormData>) {
    try {
      const { data, error } = await supabase
        .from('staff_levels')
        .update({ ...updates, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();
        
      if (error) throw new Error(`Failed to update staff level: ${error.message}`);
      setLevels(prev => prev.map(level => level.id === id ? data : level));
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to update staff level');
    }
  }

  async function deleteLevel(id: string) {
    try {
      const { error } = await supabase
        .from('staff_levels')
        .delete()
        .eq('id', id);
        
      if (error) throw new Error(`Failed to delete staff level: ${error.message}`);

      setLevels(prev => prev.filter(level => level.id !== id));
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to delete staff level');
    }
  }

  return {
    levels,
    loading,
    error,
    addLevel,
    updateLevel,
    deleteLevel,
    refresh: loadLevels
  };
}