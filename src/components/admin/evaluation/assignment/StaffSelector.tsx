import React, { useState, useEffect } from 'react';
import { Staff } from '../../../../types/staff';
import { Search, UserCheck } from 'lucide-react';
import { useSupabase } from '../../../../providers/SupabaseProvider';

type Props = {
  selectedDepartments: string[];
  selectedStaff: string[];
  onChange: (staff: string[]) => void;
  staffLevel: 'Staff' | 'HOD/Manager' | 'HR';
};

export default function StaffSelector({ selectedDepartments, selectedStaff, onChange, staffLevel }: Props) {
  const supabase = useSupabase();
  const [staff, setStaff] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadStaff();
  }, [selectedDepartments, staffLevel]);

  const loadStaff = async () => {
    try {
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
        .eq('staff_levels_junction.is_primary', true)
        .eq('staff_levels_junction.level.name', staffLevel);

      // Only filter by departments for staff evaluations
      if (selectedDepartments.length > 0) {
        query = query
          .eq('staff_departments.is_primary', true)
          .in('staff_departments.department_id', selectedDepartments);
      }

      const { data, error } = await query;

      if (error) throw error;
      setStaff(data || []);
    } catch (error) {
      console.error('Error loading staff:', error);
    } finally {
      setLoading(false);
    }
  };

  const toggleAll = () => {
    if (selectedStaff.length === staff.length) {
      onChange([]);
    } else {
      onChange(staff.map(s => s.id));
    }
  };

  const toggleStaff = (staffId: string) => {
    const newSelection = selectedStaff.includes(staffId)
      ? selectedStaff.filter(id => id !== staffId)
      : [...selectedStaff, staffId];
    onChange(newSelection);
  };

  const filteredStaff = staff.filter(member =>
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.departments?.[0]?.department?.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex justify-center items-center py-8">
        <div className="animate-pulse text-gray-500">Loading {staffLevel} members...</div>
      </div>
    );
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-sm font-medium text-gray-700">Select {staffLevel} Members</h3>
        <div className="flex items-center space-x-4">
          <div className="relative">
            <Search className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
            <input
              type="text"
              placeholder={`Search ${staffLevel}...`}
              className="pl-10 pr-4 py-2 border border-gray-300 rounded-md"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <button
            type="button"
            onClick={toggleAll}
            className="text-sm text-indigo-600 hover:text-indigo-800 flex items-center"
          >
            <UserCheck className="h-4 w-4 mr-1" />
            {selectedStaff.length === staff.length ? 'Deselect All' : 'Select All'}
          </button>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 max-h-60 overflow-y-auto">
        {filteredStaff.map((member) => (
          <button
            key={member.id}
            type="button"
            onClick={() => toggleStaff(member.id)}
            className={`p-4 text-left rounded-lg border transition-colors ${
              selectedStaff.includes(member.id)
                ? 'border-indigo-500 bg-indigo-50'
                : 'border-gray-200 hover:border-indigo-200'
            }`}
          >
            <div className="font-medium text-gray-900">{member.name}</div>
            <div className="text-sm text-gray-500">
              {member.departments?.[0]?.department?.name}
            </div>
          </button>
        ))}
        {filteredStaff.length === 0 && (
          <div className="col-span-2 text-center py-4 text-gray-500">
            No {staffLevel} members found
          </div>
        )}
      </div>
    </div>
  );
}