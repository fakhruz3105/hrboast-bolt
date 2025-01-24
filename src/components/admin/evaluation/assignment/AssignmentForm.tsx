import React, { useState } from 'react';
import { X } from 'lucide-react';
import { EvaluationForm } from '../../../../types/evaluation';
import DepartmentSelector from './DepartmentSelector';
import StaffSelector from './StaffSelector';
import ManagerSelector from './ManagerSelector';

type Props = {
  evaluation: EvaluationForm;
  onSubmit: (data: {
    departmentIds: string[];
    staffIds: string[];
    managerId: string;
  }) => Promise<void>;
  onCancel: () => void;
};

export default function AssignmentForm({ evaluation, onSubmit, onCancel }: Props) {
  const [selectedDepartments, setSelectedDepartments] = useState<string[]>([]);
  const [selectedStaff, setSelectedStaff] = useState<string[]>([]);
  const [selectedManager, setSelectedManager] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedManager || selectedStaff.length === 0) {
      alert('Please select staff members and an evaluator');
      return;
    }

    setLoading(true);
    try {
      await onSubmit({
        departmentIds: selectedDepartments,
        staffIds: selectedStaff,
        managerId: selectedManager
      });
    } catch (error) {
      console.error('Error assigning evaluation:', error);
      alert('Failed to assign evaluation');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-[100] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Assign Evaluation</h2>
                <p className="mt-1 text-sm text-gray-600">{evaluation.title}</p>
              </div>
              <button onClick={onCancel} className="text-gray-500 hover:text-gray-700">
                <X className="h-6 w-6" />
              </button>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            <DepartmentSelector
              selectedDepartments={selectedDepartments}
              onChange={setSelectedDepartments}
            />

            {selectedDepartments.length > 0 && (
              <>
                <StaffSelector
                  selectedDepartments={selectedDepartments}
                  selectedStaff={selectedStaff}
                  onChange={setSelectedStaff}
                  staffLevel="Staff"
                />

                <ManagerSelector
                  selectedDepartments={selectedDepartments}
                  selectedManager={selectedManager}
                  onChange={setSelectedManager}
                  managerLevel="HOD/Manager"
                />
              </>
            )}

            <div className="flex justify-end space-x-3 pt-4">
              <button
                type="button"
                onClick={onCancel}
                className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
                disabled={loading || !selectedManager || selectedStaff.length === 0}
              >
                {loading ? 'Assigning...' : 'Assign Evaluation'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}