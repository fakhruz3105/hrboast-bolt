import React, { useState, useEffect } from 'react';
import { Plus } from 'lucide-react';
import { Department } from '../../../types/department';
import { StaffLevel } from '../../../types/staffLevel';
import DepartmentList from '../../../components/admin/departments/DepartmentList';
import DepartmentForm from '../../../components/admin/departments/DepartmentForm';
import { useDepartments } from '../../../hooks/useDepartments';
import { useStaffLevels } from '../../../hooks/useStaffLevels';
import ErrorAlert from '../../../components/ui/ErrorAlert';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function DepartmentsPage() {
  const supabase = useSupabase();
  const { departments, loading, error, addDepartment, updateDepartment, deleteDepartment } = useDepartments();
  const { levels, loading: levelsLoading } = useStaffLevels();
  const [showForm, setShowForm] = useState(false);
  const [editingDepartment, setEditingDepartment] = useState<Department | null>(null);
  const [defaultLevels, setDefaultLevels] = useState<Record<string, StaffLevel>>({});
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    if (departments.length > 0) {
      loadDefaultLevels();
    }
  }, [departments]);

  const loadDefaultLevels = async () => {
    try {
      const { data, error } = await supabase
        .from('department_default_levels')
        .select(`
          department_id,
          level:level_id(*)
        `);

      if (error) throw error;

      const levelsMap = (data || []).reduce((acc: Record<string, StaffLevel>, curr: any) => {
        if (curr.level) {
          acc[curr.department_id] = curr.level;
        }
        return acc;
      }, {});

      setDefaultLevels(levelsMap);
    } catch (err) {
      console.error('Error loading default levels:', err);
    }
  };

  const handleSubmit = async (formData: any) => {
    try {
      const { defaultLevelId, ...departmentData } = formData;

      if (editingDepartment) {
        await updateDepartment(editingDepartment.id, departmentData);
        
        // Update default level
        if (defaultLevelId) {
          await supabase
            .from('department_default_levels')
            .upsert({
              department_id: editingDepartment.id,
              level_id: defaultLevelId
            });
        } else {
          await supabase
            .from('department_default_levels')
            .delete()
            .eq('department_id', editingDepartment.id);
        }

        toast.success('Department updated successfully');
      } else {
        const newDept = await addDepartment(departmentData);
        
        // Set default level if specified
        if (defaultLevelId) {
          await supabase
            .from('department_default_levels')
            .insert({
              department_id: newDept.id,
              level_id: defaultLevelId
            });
        }

        toast.success('Department created successfully');
      }

      setShowForm(false);
      setEditingDepartment(null);
      setErrorMessage(null);
      loadDefaultLevels();
    } catch (err) {
      setErrorMessage(err instanceof Error ? err.message : 'Failed to save department');
    }
  };

  const handleEdit = async (department: Department) => {
    setEditingDepartment(department);
    setShowForm(true);
    setErrorMessage(null);
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this department?')) return;

    try {
      await deleteDepartment(id);
      toast.success('Department deleted successfully');
      setErrorMessage(null);
    } catch (err) {
      setErrorMessage(err instanceof Error ? err.message : 'Failed to delete department');
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
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Departments</h1>
          <p className="text-sm text-gray-500 mt-1">Manage departments and their default staff levels</p>
        </div>
        <button
          onClick={() => {
            setEditingDepartment(null);
            setShowForm(true);
            setErrorMessage(null);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Department
        </button>
      </div>

      {errorMessage && (
        <ErrorAlert 
          message={errorMessage} 
          onClose={() => setErrorMessage(null)}
        />
      )}

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <h2 className="text-lg font-semibold mb-4">
            {editingDepartment ? 'Edit Department' : 'Add Department'}
          </h2>
          <DepartmentForm
            initialData={editingDepartment}
            defaultLevel={editingDepartment ? defaultLevels[editingDepartment.id] : null}
            staffLevels={levels}
            onSubmit={handleSubmit}
            onCancel={() => {
              setShowForm(false);
              setEditingDepartment(null);
              setErrorMessage(null);
            }}
          />
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <DepartmentList
          departments={departments}
          defaultLevels={defaultLevels}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      </div>
    </div>
  );
}