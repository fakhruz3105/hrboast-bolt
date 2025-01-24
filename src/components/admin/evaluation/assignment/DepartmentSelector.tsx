import React, { useState, useEffect } from 'react';
import { Department } from '../../../../types/department';
import { CheckCircle } from 'lucide-react';
import { useSupabase } from '../../../../providers/SupabaseProvider';

type Props = {
  selectedDepartments: string[];
  onChange: (departments: string[]) => void;
};

export default function DepartmentSelector({ selectedDepartments, onChange }: Props) {
  const supabase = useSupabase();
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDepartments();
  }, []);

  const loadDepartments = async () => {
    try {
      const { data, error } = await supabase
        .from('departments')
        .select('*')
        .order('name');

      if (error) throw error;
      setDepartments(data || []);
    } catch (error) {
      console.error('Error loading departments:', error);
    } finally {
      setLoading(false);
    }
  };

  const toggleAll = () => {
    if (selectedDepartments.length === departments.length) {
      onChange([]);
    } else {
      onChange(departments.map(dept => dept.id));
    }
  };

  const toggleDepartment = (deptId: string) => {
    const newSelection = selectedDepartments.includes(deptId)
      ? selectedDepartments.filter(id => id !== deptId)
      : [...selectedDepartments, deptId];
    onChange(newSelection);
  };

  if (loading) return <div>Loading departments...</div>;

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-sm font-medium text-gray-700">Select Departments</h3>
        <button
          type="button"
          onClick={toggleAll}
          className="text-sm text-indigo-600 hover:text-indigo-800 flex items-center"
        >
          <CheckCircle className="h-4 w-4 mr-1" />
          {selectedDepartments.length === departments.length ? 'Deselect All' : 'Select All'}
        </button>
      </div>

      <div className="grid grid-cols-3 gap-4">
        {departments.map((dept) => (
          <button
            key={dept.id}
            type="button"
            onClick={() => toggleDepartment(dept.id)}
            className={`p-4 text-center rounded-lg border transition-colors ${
              selectedDepartments.includes(dept.id)
                ? 'border-indigo-500 bg-indigo-50 text-indigo-700'
                : 'border-gray-200 hover:border-indigo-200 text-gray-700'
            }`}
          >
            {dept.name}
          </button>
        ))}
      </div>
    </div>
  );
}