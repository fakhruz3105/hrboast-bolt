import { useState, useEffect } from 'react';
import { Staff, StaffFormData } from '../types/staff';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

export function useStaff() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [staff, setStaff] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadStaff() {
    try {
      setLoading(true);
      // Build query
      const { data } = await supabase
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

      setStaff(data as Staff[]);
      setError(null);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load staff');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (user?.company_id) {
      loadStaff();
    } else {
      setLoading(false);
    }
  }, [user?.company_id]);

  async function addStaff(staffMember: StaffFormData) {
    try {
      const { data: userData } = await supabase.auth.getUser();
      const user = userData.user;

      const { data: roleMap } = await supabase
        .from('role_mappings')
        .select('*')
        .eq('staff_level_id', staffMember.primary_level_id)
        .single();

      // First create the staff record
      const { data: newStaff, error: staffError } = await supabase
        .from('staff')
        .insert([{
          name: staffMember.name,
          email: staffMember.email,
          phone_number: staffMember.phone_number,
          join_date: staffMember.join_date,
          status: staffMember.status,
          company_id: user?.user_metadata?.company_id,
          is_active: true,
          role_id: roleMap?.id
        }])
        .select()
        .single();

      if (staffError) throw staffError;

      // Create department associations
      const departmentAssociations = staffMember.department_ids.map(deptId => ({
        staff_id: newStaff.id,
        department_id: deptId,
        is_primary: deptId === staffMember.primary_department_id
      }));

      const { error: deptError } = await supabase
        .from('staff_departments')
        .insert(departmentAssociations);

      if (deptError) throw deptError;

      // Create level associations
      const levelAssociations = staffMember.level_ids.map(levelId => ({
        staff_id: newStaff.id,
        level_id: levelId,
        is_primary: levelId === staffMember.primary_level_id
      }));

      const { error: levelError } = await supabase
        .from('staff_levels_junction')
        .insert(levelAssociations);

      if (levelError) throw levelError;

      // Fetch the complete staff record with all associations
      const { data: completeStaff, error: fetchError } = await supabase
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
        .eq('id', newStaff.id)
        .single();

      if (fetchError) throw fetchError;
      setStaff(prev => [...prev, completeStaff]);
      toast.success('Staff member added successfully');
      return completeStaff;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to add staff');
      toast.error(error.message);
      throw error;
    }
  }

  async function updateStaff(id: string, updates: Partial<StaffFormData>) {
    try {
        // First update the staff record
        const { error: staffError } = await supabase
        .from('staff')
        .update({
          name: updates.name,
          email: updates.email,
          phone_number: updates.phone_number,
          join_date: updates.join_date,
          status: updates.status
        })
        .eq('id', id);

      if (staffError) throw staffError;

      // Update department associations if provided
      if (updates.department_ids && updates.primary_department_id) {
        // First delete existing associations
        const { error: deleteDeptError } = await supabase
          .from('staff_departments')
          .delete()
          .eq('staff_id', id);

        if (deleteDeptError) throw deleteDeptError;

        // Create new associations
        const departmentAssociations = updates.department_ids.map(deptId => ({
          staff_id: id,
          department_id: deptId,
          is_primary: deptId === updates.primary_department_id
        }));

        const { error: deptError } = await supabase
          .from('staff_departments')
          .insert(departmentAssociations);

        if (deptError) throw deptError;
      }

      // Update level associations if provided
      if (updates.level_ids && updates.primary_level_id) {
        // First delete existing associations
        const { error: deleteLevelError } = await supabase
          .from('staff_levels_junction')
          .delete()
          .eq('staff_id', id);

        if (deleteLevelError) throw deleteLevelError;

        // Create new associations
        const levelAssociations = updates.level_ids.map(levelId => ({
          staff_id: id,
          level_id: levelId,
          is_primary: levelId === updates.primary_level_id
        }));

        const { error: levelError } = await supabase
          .from('staff_levels_junction')
          .insert(levelAssociations);

        if (levelError) throw levelError;
      }

      // Fetch the updated staff record with all associations
      const { data: updatedStaff, error: fetchError } = await supabase
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
        .eq('id', id)
        .single();

      if (fetchError) throw fetchError;
      setStaff(prev => prev.map(s => s.id === id ? updatedStaff : s));
      toast.success('Staff member updated successfully');
      return updatedStaff;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update staff');
      toast.error(error.message);
      throw error;
    }
  }

  async function deleteStaff(id: string) {
    try {
      const { error } = await supabase
        .from('staff')
        .delete()
        .eq('id', id);
        
      if (error) throw error;
      setStaff(prev => prev.filter(s => s.id !== id));
      toast.success('Staff member deleted successfully');
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to delete staff');
      toast.error(error.message);
      throw error;
    }
  }

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