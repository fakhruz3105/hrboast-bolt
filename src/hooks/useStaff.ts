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

  useEffect(() => {
    if (user?.email) {
      loadStaff();
    }
  }, [user?.email]);

  const loadStaff = async () => {
    try {
      // First get the company ID for the current user
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (staffError) throw staffError;
      if (!staffData?.company_id) {
        throw new Error('Company not found. Please contact administrator.');
      }

      // Then load staff for this company
      const { data, error } = await supabase
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
          )
        `)
        .eq('company_id', staffData.company_id)
        .order('name');

      if (error) throw error;
      setStaff(data || []);
      setError(null);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to load staff';
      console.error('Error loading staff:', error);
      setError(new Error(message));
      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  const addStaff = async (staffMember: StaffFormData) => {
    try {
      // Get company ID for current user
      const { data: userData, error: userError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (userError) throw userError;
      if (!userData?.company_id) {
        throw new Error('Company not found. Please contact administrator.');
      }

      // First create the staff record
      const { data: newStaff, error: staffError } = await supabase
        .from('staff')
        .insert([{
          name: staffMember.name,
          email: staffMember.email,
          phone_number: staffMember.phone_number,
          join_date: staffMember.join_date,
          status: staffMember.status,
          company_id: userData.company_id,
          is_active: true,
          role_id: staffMember.role_id
        }])
        .select()
        .single();

      if (staffError) {
        if (staffError.code === '23505') { // Unique violation
          throw new Error('A staff member with this email already exists.');
        }
        throw staffError;
      }

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
          )
        `)
        .eq('id', newStaff.id)
        .single();

      if (fetchError) throw fetchError;

      setStaff(prev => [...prev, completeStaff]);
      setError(null);
      toast.success('Staff member added successfully');
      return completeStaff;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to add staff';
      console.error('Error adding staff:', error);
      setError(new Error(message));
      toast.error(message);
      throw error;
    }
  };

  const updateStaff = async (id: string, updates: Partial<StaffFormData>) => {
    try {
      // First update the staff record
      const { error: staffError } = await supabase
        .from('staff')
        .update({
          name: updates.name,
          email: updates.email,
          phone_number: updates.phone_number,
          join_date: updates.join_date,
          status: updates.status,
          role_id: updates.role_id
        })
        .eq('id', id);

      if (staffError) {
        if (staffError.code === '23505') { // Unique violation
          throw new Error('A staff member with this email already exists.');
        }
        throw staffError;
      }

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
          )
        `)
        .eq('id', id)
        .single();

      if (fetchError) throw fetchError;

      setStaff(prev => prev.map(s => s.id === id ? updatedStaff : s));
      setError(null);
      toast.success('Staff member updated successfully');
      return updatedStaff;
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to update staff';
      console.error('Error updating staff:', error);
      setError(new Error(message));
      toast.error(message);
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
      setError(null);
      toast.success('Staff member deleted successfully');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to delete staff';
      console.error('Error deleting staff:', error);
      setError(new Error(message));
      toast.error(message);
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