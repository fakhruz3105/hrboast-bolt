import { supabase } from '../supabase';
import { Staff, StaffFormData } from '../../types/staff';
import { handleError } from '../utils/errorHandler';

export async function fetchStaff(): Promise<Staff[]> {
  try {
    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;

    // Build query
    let query = supabase
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

    // Add company filter if not super admin
    if (user?.user_metadata?.role !== 'super_admin' && user?.user_metadata?.company_id) {
      query = query.eq('company_id', user.user_metadata.company_id);
    }

    const { data, error } = await query;
      
    if (error) throw error;
    return data || [];
  } catch (error) {
    handleError(error);
    throw error;
  }
}

export async function createStaff(staffMember: StaffFormData): Promise<Staff> {
  try {
    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;

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
        role_id: staffMember.role_id
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
    return completeStaff;
  } catch (error) {
    handleError(error);
    throw error;
  }
}

export async function updateStaff(id: string, updates: Partial<StaffFormData>): Promise<Staff> {
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
    return updatedStaff;
  } catch (error) {
    handleError(error);
    throw error;
  }
}

export async function deleteStaff(id: string): Promise<void> {
  try {
    const { error } = await supabase
      .from('staff')
      .delete()
      .eq('id', id);
      
    if (error) throw error;
  } catch (error) {
    handleError(error);
    throw error;
  }
}