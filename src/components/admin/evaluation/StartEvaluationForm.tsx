import React, { useState, useEffect } from 'react';
import { X, Search, CheckCircle, UserCheck } from 'lucide-react';
import { EvaluationForm } from '../../../types/evaluation';
import { Staff } from '../../../types/staff';
import { supabase } from '../../../lib/supabase';

type Props = {
  evaluation: EvaluationForm;
  onSubmit: (staffIds: string[], managerId: string) => Promise<void>;
  onClose: () => void;
};

export default function StartEvaluationForm({ evaluation, onSubmit, onClose }: Props) {
  const [departments, setDepartments] = useState<{id: string; name: string}[]>([]);
  const [selectedDepartments, setSelectedDepartments] = useState<Set<string>>(new Set());
  const [staff, setStaff] = useState<Staff[]>([]);
  const [managers, setManagers] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  
  const [selectedStaff, setSelectedStaff] = useState<Set<string>>(new Set());
  const [selectedManager, setSelectedManager] = useState('');

  useEffect(() => {
    loadDepartments();
  }, []);

  useEffect(() => {
    if (selectedDepartments.size > 0) {
      loadStaffAndManagers(Array.from(selectedDepartments));
    } else {
      setStaff([]);
      setManagers([]);
      setSelectedStaff(new Set());
      setSelectedManager('');
    }
  }, [selectedDepartments]);

  const loadDepartments = async () => {
    try {
      const { data, error } = await supabase
        .from('departments')
        .select('id, name')
        .order('name');

      if (error) throw error;
      setDepartments(data || []);
    } catch (error) {
      console.error('Error loading departments:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadStaffAndManagers = async (departmentIds: string[]) => {
    try {
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select(`
          *,
          department:departments(name),
          level:staff_levels(name)
        `)
        .in('department_id', departmentIds)
        .eq('status', 'permanent')
        .neq('level.name', 'HOD/Manager');

      if (staffError) throw staffError;

      const { data: managerData, error: managerError } = await supabase
        .from('staff')
        .select(`
          *,
          department:departments(name),
          level:staff_levels(name)
        `)
        .in('department_id', departmentIds)
        .eq('status', 'permanent')
        .eq('level.name', 'HOD/Manager');

      if (managerError) throw managerError;

      setStaff(staffData || []);
      setManagers(managerData || []);
    } catch (error) {
      console.error('Error loading staff and managers:', error);
    }
  };

  const toggleDepartment = (departmentId: string) => {
    const newSelection = new Set(selectedDepartments);
    if (newSelection.has(departmentId)) {
      newSelection.delete(departmentId);
    } else {
      newSelection.add(departmentId);
    }
    setSelectedDepartments(newSelection);
  };

  const toggleAllDepartments = () => {
    if (selectedDepartments.size === departments.length) {
      setSelectedDepartments(new Set());
    } else {
      setSelectedDepartments(new Set(departments.map(dept => dept.id)));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (selectedStaff.size === 0 || !selectedManager) {
      alert('Please select staff members and a manager');
      return;
    }
    await onSubmit(Array.from(selectedStaff), selectedManager);
  };

  const toggleStaffSelection = (staffId: string) => {
    const newSelection = new Set(selectedStaff);
    if (newSelection.has(staffId)) {
      newSelection.delete(staffId);
    } else {
      newSelection.add(staffId);
    }
    setSelectedStaff(newSelection);
  };

  const toggleAllStaff = () => {
    if (selectedStaff.size === staff.length) {
      setSelectedStaff(new Set());
    } else {
      setSelectedStaff(new Set(staff.map(s => s.id)));
    }
  };

  const filteredStaff = staff.filter(member => 
    member.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Start Evaluation</h2>
                <p className="mt-1 text-sm text-gray-600">{evaluation.title}</p>
              </div>
              <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
                <X className="h-6 w-6" />
              </button>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="p-6">
            <div className="space-y-6">
              {/* Department Selection */}
              <div>
                <div className="flex justify-between items-center mb-4">
                  <h3 className="text-sm font-medium text-gray-700">Select Departments</h3>
                  <button
                    type="button"
                    onClick={toggleAllDepartments}
                    className="text-sm text-indigo-600 hover:text-indigo-800 flex items-center"
                  >
                    <CheckCircle className="h-4 w-4 mr-1" />
                    {selectedDepartments.size === departments.length ? 'Deselect All' : 'Select All'}
                  </button>
                </div>
                <div className="grid grid-cols-3 gap-4">
                  {departments.map((dept) => (
                    <button
                      key={dept.id}
                      type="button"
                      onClick={() => toggleDepartment(dept.id)}
                      className={`p-4 text-center rounded-lg border transition-colors ${
                        selectedDepartments.has(dept.id)
                          ? 'border-indigo-500 bg-indigo-50 text-indigo-700'
                          : 'border-gray-200 hover:border-indigo-200 text-gray-700'
                      }`}
                    >
                      {dept.name}
                    </button>
                  ))}
                </div>
              </div>

              {selectedDepartments.size > 0 && (
                <>
                  {/* Staff Search and Selection */}
                  <div>
                    <div className="flex justify-between items-center mb-4">
                      <h3 className="text-sm font-medium text-gray-700">Select Staff Members</h3>
                      <div className="flex items-center space-x-4">
                        <div className="relative">
                          <Search className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                          <input
                            type="text"
                            placeholder="Search staff..."
                            className="pl-10 pr-4 py-2 border border-gray-300 rounded-md"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                          />
                        </div>
                        <button
                          type="button"
                          onClick={toggleAllStaff}
                          className="text-sm text-indigo-600 hover:text-indigo-800 flex items-center"
                        >
                          <UserCheck className="h-4 w-4 mr-1" />
                          {selectedStaff.size === staff.length ? 'Deselect All' : 'Select All'}
                        </button>
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4 max-h-60 overflow-y-auto">
                      {filteredStaff.map((member) => (
                        <button
                          key={member.id}
                          type="button"
                          onClick={() => toggleStaffSelection(member.id)}
                          className={`p-4 text-left rounded-lg border transition-colors ${
                            selectedStaff.has(member.id)
                              ? 'border-indigo-500 bg-indigo-50'
                              : 'border-gray-200 hover:border-indigo-200'
                          }`}
                        >
                          <div className="font-medium text-gray-900">{member.name}</div>
                          <div className="text-sm text-gray-500">{member.department?.name}</div>
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Manager Selection */}
                  <div>
                    <h3 className="text-sm font-medium text-gray-700 mb-4">Select Manager</h3>
                    <div className="grid grid-cols-2 gap-4">
                      {managers.map((manager) => (
                        <button
                          key={manager.id}
                          type="button"
                          onClick={() => setSelectedManager(manager.id)}
                          className={`p-4 text-left rounded-lg border transition-colors ${
                            selectedManager === manager.id
                              ? 'border-indigo-500 bg-indigo-50'
                              : 'border-gray-200 hover:border-indigo-200'
                          }`}
                        >
                          <div className="font-medium text-gray-900">{manager.name}</div>
                          <div className="text-sm text-gray-500">{manager.department?.name}</div>
                        </button>
                      ))}
                    </div>
                  </div>
                </>
              )}
            </div>

            <div className="mt-6 flex justify-end space-x-3">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
                disabled={selectedDepartments.size === 0 || selectedStaff.size === 0 || !selectedManager}
              >
                Start Evaluation
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}