import React, { useState, useEffect } from 'react';
import { supabase } from '../../../../lib/supabase';
import { Staff } from '../../../../types/staff';

type Props = {
  selectedDepartments: string[];
  selectedManager: string;
  onChange: (managerId: string) => void;
  managerLevel: 'HOD/Manager' | 'C-Suite';
};

export default function ManagerSelector({ selectedDepartments, selectedManager, onChange, managerLevel }: Props) {
  const [managers, setManagers] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadManagers();
  }, [selectedDepartments, managerLevel]);

  const loadManagers = async () => {
    try {
      // First try to get department managers
      let query = supabase
        .from('staff')
        .select(`
          *,
          departments:staff_departments!inner(
            is_primary,
            department:departments!inner(
              id,
              name
            )
          ),
          levels:staff_levels_junction!inner(
            is_primary,
            level:staff_levels!inner(
              id,
              name,
              rank
            )
          )
        `)
        .eq('status', 'permanent')
        .eq('staff_levels_junction.is_primary', true);

      if (managerLevel === 'HOD/Manager') {
        // For staff evaluations, first try to get HOD/Managers
        if (selectedDepartments.length > 0) {
          query = query
            .eq('staff_departments.is_primary', true)
            .in('staff_departments.department_id', selectedDepartments)
            .eq('staff_levels_junction.level.name', 'HOD/Manager');
        }

        const { data: hodManagers, error: hodError } = await query;

        if (!hodError && hodManagers && hodManagers.length > 0) {
          setManagers(hodManagers);
          setLoading(false);
          return;
        }

        // If no HOD/Manager found, get C-Suite and HR
        const { data: fallbackManagers, error: fallbackError } = await supabase
          .from('staff')
          .select(`
            *,
            departments:staff_departments!inner(
              is_primary,
              department:departments!inner(
                id,
                name
              )
            ),
            levels:staff_levels_junction!inner(
              is_primary,
              level:staff_levels!inner(
                id,
                name,
                rank
              )
            )
          `)
          .eq('status', 'permanent')
          .eq('staff_levels_junction.is_primary', true)
          .in('staff_levels_junction.level.name', ['C-Suite', 'HR']);

        if (fallbackError) throw fallbackError;
        setManagers(fallbackManagers || []);
      } else {
        // For HOD evaluations, get only C-Suite members
        query = query.eq('staff_levels_junction.level.name', 'C-Suite');
        const { data: csuiteManagers, error: csuiteError } = await query;

        if (csuiteError) throw csuiteError;
        setManagers(csuiteManagers || []);
      }
    } catch (error) {
      console.error('Error loading managers:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-8">
        <div className="animate-pulse text-gray-500">Loading evaluators...</div>
      </div>
    );
  }

  return (
    <div>
      <h3 className="text-sm font-medium text-gray-700 mb-4">Select Evaluator</h3>
      <div className="grid grid-cols-2 gap-4">
        {managers.map((manager) => (
          <button
            key={manager.id}
            type="button"
            onClick={() => onChange(manager.id)}
            className={`p-4 text-left rounded-lg border transition-colors ${
              selectedManager === manager.id
                ? 'border-indigo-500 bg-indigo-50'
                : 'border-gray-200 hover:border-indigo-200'
            }`}
          >
            <div className="font-medium text-gray-900">{manager.name}</div>
            <div className="text-sm text-gray-500">
              {manager.departments?.[0]?.department?.name} - {manager.levels?.[0]?.level?.name}
            </div>
          </button>
        ))}
        {managers.length === 0 && (
          <div className="col-span-2 text-center py-4 text-gray-500">
            No evaluators found. Please contact HR.
          </div>
        )}
      </div>
    </div>
  );
}