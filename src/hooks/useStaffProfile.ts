import { useState, useEffect } from 'react';
import { Staff } from '../types/staff';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useStaffProfile() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [staff, setStaff] = useState<Staff | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (user?.email) {
      loadProfile();
    }
  }, [user?.email]);

  const loadProfile = async () => {
    try {
      setLoading(true);

      // Get staff details with company info
      const { data, error: fetchError } = await supabase
        .from('staff')
        .select(`
          *,
          departments:staff_departments(
            id,
            is_primary,
            department:departments(
              id,
              name
            )
          ),
          levels:staff_levels_junction(
            id,
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
          ),
          company:company_id(
            id,
            name,
            email
          )
        `)
        .eq('email', user.email)
        .single();

      if (fetchError) throw fetchError;
      if (!data) throw new Error('Staff profile not found');

      setStaff(data);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load profile');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  };

  const updateProfile = async (updates: Partial<Staff>) => {
    try {
      if (!staff?.id) throw new Error('No staff ID found');

      const { error: updateError } = await supabase
        .from('staff')
        .update(updates)
        .eq('id', staff.id);

      if (updateError) throw updateError;
      await loadProfile();
      toast.success('Profile updated successfully');
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update profile');
      toast.error(error.message);
      throw error;
    }
  };

  return {
    staff,
    loading,
    error,
    updateProfile,
    refresh: loadProfile
  };
}