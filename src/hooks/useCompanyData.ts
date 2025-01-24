import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useCompanyData<T>(tableName: string) {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [data, setData] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (user?.id) {
      loadData();
    }
  }, [user?.id]);

  const loadData = async () => {
    try {
      setLoading(true);
      const companyClient = await getCompanyClient(user!.id);
      
      if (!companyClient) {
        throw new Error('Could not connect to company database');
      }

      const { data: result, error } = await companyClient
        .from(tableName)
        .select('*');

      if (error) throw error;
      setData(result || []);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load data');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  const insert = async (record: Partial<T>) => {
    try {
      const companyClient = await getCompanyClient(user!.id);
      
      if (!companyClient) {
        throw new Error('Could not connect to company database');
      }

      const { data: result, error } = await companyClient
        .from(tableName)
        .insert([record])
        .select()
        .single();

      if (error) throw error;
      
      setData(prev => [...prev, result]);
      return result;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to insert record');
      toast.error(error.message);
      throw error;
    }
  };

  const update = async (id: string, updates: Partial<T>) => {
    try {
      const companyClient = await getCompanyClient(user!.id);
      
      if (!companyClient) {
        throw new Error('Could not connect to company database');
      }

      const { data: result, error } = await companyClient
        .from(tableName)
        .update(updates)
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      
      setData(prev => prev.map(item => 
        (item as any).id === id ? result : item
      ));
      return result;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update record');
      toast.error(error.message);
      throw error;
    }
  };

  const remove = async (id: string) => {
    try {
      const companyClient = await getCompanyClient(user!.id);
      
      if (!companyClient) {
        throw new Error('Could not connect to company database');
      }

      const { error } = await companyClient
        .from(tableName)
        .delete()
        .eq('id', id);

      if (error) throw error;
      
      setData(prev => prev.filter(item => (item as any).id !== id));
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to delete record');
      toast.error(error.message);
      throw error;
    }
  };

  return {
    data,
    loading,
    error,
    refresh: loadData,
    insert,
    update,
    remove
  };
}