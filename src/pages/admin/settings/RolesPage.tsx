import React, { useState, useEffect } from 'react';
import { supabase } from '../../../lib/supabase';
import { RoleMapping } from '../../../types/role';
import RolesList from '../../../components/admin/settings/roles/RolesList';
import RoleMappingForm from '../../../components/admin/settings/roles/RoleMappingForm';
import { useStaffLevels } from '../../../hooks/useStaffLevels';
import { toast } from 'react-hot-toast';

export default function RolesPage() {
  const { levels, loading: levelsLoading } = useStaffLevels();
  const [roleMappings, setRoleMappings] = useState<RoleMapping[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingMapping, setEditingMapping] = useState<RoleMapping | null>(null);

  useEffect(() => {
    loadRoleMappings();
  }, []);

  const loadRoleMappings = async () => {
    try {
      const { data, error } = await supabase
        .from('role_mappings')
        .select(`
          *,
          staff_level:staff_level_id (
            id,
            name,
            description,
            rank
          )
        `)
        .order('created_at');

      if (error) throw error;
      setRoleMappings(data || []);
    } catch (error) {
      console.error('Error loading role mappings:', error);
      toast.error('Failed to load role mappings');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (formData: { staff_level_id: string; role: string }) => {
    try {
      const { error } = await supabase.rpc('update_role_mapping', {
        p_staff_level_id: formData.staff_level_id,
        p_role: formData.role
      });

      if (error) throw error;

      await loadRoleMappings();
      setEditingMapping(null);
      toast.success('Role mapping updated successfully');
    } catch (error) {
      console.error('Error saving role mapping:', error);
      toast.error('Failed to update role mapping');
      throw error;
    }
  };

  const handleDelete = async (mapping: RoleMapping) => {
    if (!window.confirm('Are you sure you want to delete this role mapping?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('role_mappings')
        .delete()
        .eq('id', mapping.id);

      if (error) throw error;

      await loadRoleMappings();
      toast.success('Role mapping deleted successfully');
    } catch (error) {
      console.error('Error deleting role mapping:', error);
      toast.error('Failed to delete role mapping');
    }
  };

  if (loading || levelsLoading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            <div className="h-12 bg-gray-200 rounded"></div>
            <div className="h-64 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Role Management</h1>
          <p className="text-sm text-gray-500 mt-1">Manage staff level role assignments</p>
        </div>

        <div className="bg-white rounded-lg shadow-sm">
          <div className="p-6 border-b border-gray-200">
            <h2 className="text-lg font-medium text-gray-900 mb-4">Assign Role</h2>
            <RoleMappingForm
              staffLevels={levels.filter(level => 
                !roleMappings.some(mapping => 
                  mapping.staff_level_id === level.id && mapping.id !== editingMapping?.id
                )
              )}
              onSubmit={handleSubmit}
            />
          </div>

          <div className="p-6">
            <h2 className="text-lg font-medium text-gray-900 mb-4">Current Role Mappings</h2>
            <RolesList 
              roleMappings={roleMappings} 
              onEdit={setEditingMapping}
              onDelete={handleDelete}
            />
          </div>
        </div>
      </div>
    </div>
  );
}