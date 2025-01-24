import React, { useState, useEffect } from 'react';
import { CheckCircle, XCircle, AlertCircle, Calendar, Clock, UserCheck } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

type ProbationStaff = {
  id: string;
  name: string;
  email: string;
  join_date: string;
  probation_end_date: string;
  department_name: string;
  level_name: string;
  days_remaining: number;
};

export default function ProbationStaffPage() {
  const supabase = useSupabase();
  const [staff, setStaff] = useState<ProbationStaff[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedStaff, setSelectedStaff] = useState<ProbationStaff | null>(null);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [action, setAction] = useState<'confirm' | 'discontinue' | null>(null);
  const [reason, setReason] = useState('');

  useEffect(() => {
    loadProbationStaff();
  }, []);

  const loadProbationStaff = async () => {
    try {
      const { data, error } = await supabase
        .from('staff')
        .select(`
          id,
          name,
          email,
          join_date,
          departments:staff_departments(
            is_primary,
            department:departments(name)
          ),
          levels:staff_levels_junction(
            is_primary,
            level:staff_levels(name)
          )
        `)
        .eq('status', 'probation')
        .order('join_date');

      if (error) throw error;

      // Transform data to include probation end date and days remaining
      const transformedData = (data || []).map(staff => {
        const joinDate = new Date(staff.join_date);
        const probationEndDate = new Date(joinDate);
        probationEndDate.setMonth(probationEndDate.getMonth() + 3);
        
        const today = new Date();
        const daysRemaining = Math.ceil((probationEndDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));

        return {
          id: staff.id,
          name: staff.name,
          email: staff.email,
          join_date: staff.join_date,
          probation_end_date: probationEndDate.toISOString(),
          department_name: staff.departments?.find(d => d.is_primary)?.department?.name || 'N/A',
          level_name: staff.levels?.find(l => l.is_primary)?.level?.name || 'N/A',
          days_remaining: daysRemaining
        };
      });

      setStaff(transformedData);
    } catch (error) {
      console.error('Error loading probation staff:', error);
      toast.error('Failed to load probation staff');
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmPermanent = async () => {
    if (!selectedStaff) return;

    try {
      const { error } = await supabase
        .from('staff')
        .update({ status: 'permanent' })
        .eq('id', selectedStaff.id);

      if (error) throw error;

      toast.success(`${selectedStaff.name} has been confirmed as permanent staff`);
      setShowConfirmation(false);
      setSelectedStaff(null);
      setAction(null);
      setReason('');
      loadProbationStaff();
    } catch (error) {
      console.error('Error confirming staff:', error);
      toast.error('Failed to confirm staff');
    }
  };

  const handleDiscontinue = async () => {
    if (!selectedStaff || !reason) return;

    try {
      const { error } = await supabase
        .from('staff')
        .update({ 
          status: 'resigned',
          is_active: false
        })
        .eq('id', selectedStaff.id);

      if (error) throw error;

      // Create a record in HR letters for documentation
      const { error: letterError } = await supabase
        .from('hr_letters')
        .insert([{
          staff_id: selectedStaff.id,
          title: 'Probation Discontinuation Notice',
          type: 'notice',
          content: {
            type: 'probation_discontinuation',
            reason: reason,
            date: new Date().toISOString()
          },
          status: 'completed'
        }]);

      if (letterError) throw letterError;

      toast.success(`${selectedStaff.name}'s probation has been discontinued`);
      setShowConfirmation(false);
      setSelectedStaff(null);
      setAction(null);
      setReason('');
      loadProbationStaff();
    } catch (error) {
      console.error('Error discontinuing staff:', error);
      toast.error('Failed to discontinue staff');
    }
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-3 gap-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-24 bg-gray-200 rounded"></div>
            ))}
          </div>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Manage Probation Staff</h1>
        <p className="mt-1 text-sm text-gray-500">Review and manage staff under probation</p>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-indigo-100 text-indigo-600">
              <UserCheck className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total Probation Staff</p>
              <p className="text-2xl font-semibold text-gray-900">{staff.length}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-yellow-100 text-yellow-600">
              <Clock className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Ending Soon</p>
              <p className="text-2xl font-semibold text-gray-900">
                {staff.filter(s => s.days_remaining <= 14 && s.days_remaining > 0).length}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-red-100 text-red-600">
              <AlertCircle className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Overdue Review</p>
              <p className="text-2xl font-semibold text-gray-900">
                {staff.filter(s => s.days_remaining <= 0).length}
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Staff List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Level</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Join Date</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">End Date</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {staff.map((member) => (
                <tr key={member.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{member.name}</div>
                    <div className="text-sm text-gray-500">{member.email}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {member.department_name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {member.level_name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(member.join_date).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(member.probation_end_date).toLocaleDateString()}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                      member.days_remaining > 14
                        ? 'bg-green-100 text-green-800'
                        : member.days_remaining > 0
                        ? 'bg-yellow-100 text-yellow-800'
                        : 'bg-red-100 text-red-800'
                    }`}>
                      {member.days_remaining > 14
                        ? `${member.days_remaining} days left`
                        : member.days_remaining > 0
                        ? `${member.days_remaining} days left (Review Soon)`
                        : `${Math.abs(member.days_remaining)} days overdue`}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      onClick={() => {
                        setSelectedStaff(member);
                        setAction('confirm');
                        setShowConfirmation(true);
                      }}
                      className="text-green-600 hover:text-green-900 mr-3"
                      title="Confirm as Permanent"
                    >
                      <CheckCircle className="h-5 w-5" />
                    </button>
                    <button
                      onClick={() => {
                        setSelectedStaff(member);
                        setAction('discontinue');
                        setShowConfirmation(true);
                      }}
                      className="text-red-600 hover:text-red-900"
                      title="Discontinue Probation"
                    >
                      <XCircle className="h-5 w-5" />
                    </button>
                  </td>
                </tr>
              ))}
              {staff.length === 0 && (
                <tr>
                  <td colSpan={7} className="px-6 py-4 text-center text-sm text-gray-500">
                    No staff members under probation
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Confirmation Modal */}
      {showConfirmation && selectedStaff && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              {action === 'confirm' ? 'Confirm Permanent Status' : 'Discontinue Probation'}
            </h3>
            
            <div className="mb-4">
              <p className="text-sm text-gray-500">
                {action === 'confirm'
                  ? `Are you sure you want to confirm ${selectedStaff.name} as a permanent staff member?`
                  : `Are you sure you want to discontinue ${selectedStaff.name}'s probation?`}
              </p>
              
              {action === 'discontinue' && (
                <div className="mt-4">
                  <label className="block text-sm font-medium text-gray-700">
                    Reason for Discontinuation
                  </label>
                  <textarea
                    required
                    rows={3}
                    className="mt-1 block w-full rounded-md border border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                    value={reason}
                    onChange={(e) => setReason(e.target.value)}
                  />
                </div>
              )}

              <div className="mt-4 bg-gray-50 p-4 rounded-md">
                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <span className="font-medium text-gray-500">Department:</span>
                    <span className="ml-2 text-gray-900">{selectedStaff.department_name}</span>
                  </div>
                  <div>
                    <span className="font-medium text-gray-500">Level:</span>
                    <span className="ml-2 text-gray-900">{selectedStaff.level_name}</span>
                  </div>
                  <div>
                    <span className="font-medium text-gray-500">Join Date:</span>
                    <span className="ml-2 text-gray-900">
                      {new Date(selectedStaff.join_date).toLocaleDateString()}
                    </span>
                  </div>
                  <div>
                    <span className="font-medium text-gray-500">End Date:</span>
                    <span className="ml-2 text-gray-900">
                      {new Date(selectedStaff.probation_end_date).toLocaleDateString()}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end space-x-3">
              <button
                type="button"
                onClick={() => {
                  setShowConfirmation(false);
                  setSelectedStaff(null);
                  setAction(null);
                  setReason('');
                }}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={action === 'confirm' ? handleConfirmPermanent : handleDiscontinue}
                disabled={action === 'discontinue' && !reason.trim()}
                className={`px-4 py-2 text-sm font-medium text-white rounded-md ${
                  action === 'confirm'
                    ? 'bg-green-600 hover:bg-green-700'
                    : 'bg-red-600 hover:bg-red-700'
                } disabled:opacity-50 disabled:cursor-not-allowed`}
              >
                {action === 'confirm' ? 'Confirm Permanent' : 'Discontinue Probation'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}