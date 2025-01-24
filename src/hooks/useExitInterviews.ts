import { useState, useEffect } from 'react';
import { ExitInterview, ExitInterviewFormData } from '../types/exitInterview';
import { useSupabase } from '../providers/SupabaseProvider';

export function useExitInterviews() {
  const supabase = useSupabase();
  const [interviews, setInterviews] = useState<ExitInterview[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    loadExitInterviews();
  }, []);

  async function loadExitInterviews() {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('exit_interviews')
        .select(`
          *,
          staff:staff_id(id, name, email)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setInterviews(data || []);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load exit interviews'));
    } finally {
      setLoading(false);
    }
  }

  async function createInterview(formData: ExitInterviewFormData) {
    try {
      const { data, error } = await supabase
        .from('exit_interviews')
        .insert([{
          ...formData,
          hr_approval: 'pending',
          admin_approval: 'pending',
          status: 'pending'
        }])
        .select()
        .single();

      if (error) throw error;
      setInterviews(prev => [data, ...prev]);
      return data;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to create exit interview');
    }
  }

  return {
    interviews,
    loading,
    error,
    createInterview,
    refresh: loadExitInterviews
  };
}