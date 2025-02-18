import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { useStaff } from '../../../hooks/useStaff';
import StaffSelector from '../../../components/admin/staff/StaffSelector';
import ExitInterviewList from '../../../components/admin/interviews/exit/ExitInterviewList';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function ExitInterviewPage() {
  const supabase = useSupabase();
  const { staff, loading: staffLoading } = useStaff();
  const [showStaffSelector, setShowStaffSelector] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleAssignInterview = async (staffId: string) => {
    try {
      setLoading(true);

      // Create HR letter for exit interview
      const { error: letterError } = await supabase
        .from('hr_letters')
        .insert([{
          staff_id: staffId,
          title: 'Exit Interview Form',
          type: 'interview',
          content: {
            type: 'exit',
            status: 'pending'
          },
          status: 'pending',
          issued_date: new Date().toISOString()
        }]);

      if (letterError) throw letterError;

      setShowStaffSelector(false);
      toast.success('Exit interview form has been assigned successfully');
    } catch (error) {
      console.error('Error assigning exit interview:', error);
      toast.error('Failed to assign exit interview form');
    } finally {
      setLoading(false);
    }
  };

  if (staffLoading) {
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
          <h1 className="text-2xl font-bold text-gray-900">Exit Interviews</h1>
          <p className="text-gray-600 mt-1">Manage staff exit interviews</p>
        </div>
        <button
          onClick={() => setShowStaffSelector(true)}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Assign Exit Interview
        </button>
      </div>

      {showStaffSelector && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white p-6 rounded-lg shadow-lg max-w-md w-full">
            <h2 className="text-lg font-semibold mb-4">Select Staff Member</h2>
            <StaffSelector
              staff={staff.filter(s => s.status !== 'resigned')}
              onSelect={handleAssignInterview}
              onCancel={() => setShowStaffSelector(false)}
              loading={loading}
            />
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <ExitInterviewList />
      </div>
    </div>
  );
}