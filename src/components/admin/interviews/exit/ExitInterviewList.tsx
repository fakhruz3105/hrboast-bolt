import React, { useState, useEffect } from 'react';
import { useAuth } from '../../../../contexts/AuthContext';
import { Eye, Download, Trash2 } from 'lucide-react';
import ExitInterviewViewer from './ExitInterviewViewer';
import { toast } from 'react-hot-toast';
import { generateExitInterviewPDF } from '../../../../utils/exitInterviewPDF';
import { useSupabase } from '../../../../providers/SupabaseProvider';

export default function ExitInterviewList() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [interviews, setInterviews] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedInterview, setSelectedInterview] = useState<any>(null);

  useEffect(() => {
    if (user?.email) {
      loadExitInterviews();
    }
  }, [user?.email]);

  const loadExitInterviews = async () => {
    try {
      if (!user?.email) {
        toast.error('User not found');
        return;
      }

      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('id, company_id')
        .eq('email', user.email)
        .single();

      if (staffError) throw staffError;
      if (!staffData) {
        toast.error('Staff record not found');
        return;
      }

      const { data, error } = await supabase.rpc('get_company_exit_interviews', {
        p_company_id: staffData.company_id
      });

      if (error) throw error;
      setInterviews(data || []);
    } catch (error) {
      console.error('Error loading exit interviews:', error);
      toast.error('Failed to load exit interviews');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (interview: any) => {
    if (!window.confirm('Are you sure you want to delete this exit interview?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('hr_letters')
        .delete()
        .eq('id', interview.id);

      if (error) throw error;

      toast.success('Exit interview deleted successfully');
      loadExitInterviews();
    } catch (error) {
      console.error('Error deleting exit interview:', error);
      toast.error('Failed to delete exit interview');
    }
  };

  const handleDownload = async (interview: any) => {
    try {
      generateExitInterviewPDF(interview);
      toast.success('Exit interview downloaded successfully');
    } catch (error) {
      console.error('Error downloading exit interview:', error);
      toast.error('Failed to download exit interview');
    }
  };

  if (loading) {
    return (
      <div className="animate-pulse">
        <div className="h-64 bg-gray-200 rounded"></div>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reason</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Working Date</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {interviews.map((interview) => (
            <tr key={interview.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">{interview.staff_name}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {interview.department_name}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800">
                  {formatReason(interview.content?.reason)}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {interview.content?.lastWorkingDate ? 
                  new Date(interview.content.lastWorkingDate).toLocaleDateString() : 
                  '-'
                }
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                  interview.status === 'submitted' 
                    ? 'bg-green-100 text-green-800'
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {interview.status}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div className="flex justify-end space-x-2">
                  <button
                    onClick={() => setSelectedInterview(interview)}
                    className="text-indigo-600 hover:text-indigo-900"
                    title="View Details"
                  >
                    <Eye className="h-4 w-4" />
                  </button>
                  {interview.status === 'submitted' && (
                    <button
                      onClick={() => handleDownload(interview)}
                      className="text-green-600 hover:text-green-900"
                      title="Download Interview"
                    >
                      <Download className="h-4 w-4" />
                    </button>
                  )}
                  <button
                    onClick={() => handleDelete(interview)}
                    className="text-red-600 hover:text-red-900"
                    title="Delete Interview"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {interviews.length === 0 && (
            <tr>
              <td colSpan={6} className="px-6 py-4 text-center text-sm text-gray-500">
                No exit interviews found
              </td>
            </tr>
          )}
        </tbody>
      </table>

      {selectedInterview && (
        <ExitInterviewViewer
          interview={selectedInterview}
          onClose={() => setSelectedInterview(null)}
        />
      )}
    </div>
  );
}

function formatReason(reason?: string): string {
  if (!reason) return '-';
  return reason.split('_').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ');
}