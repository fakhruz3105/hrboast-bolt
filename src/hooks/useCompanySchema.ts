import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useCompanySchema() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [schemaName, setSchemaName] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (user?.id) {
      loadSchema();
    }
  }, [user?.id]);

  const loadSchema = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase.rpc('get_company_schema', {
        p_user_id: user!.id
      });

      if (error) throw error;
      setSchemaName(data);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load company schema');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  return {
    schemaName,
    loading,
    error,
    refresh: loadSchema
  };
}