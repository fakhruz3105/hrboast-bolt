import React, { useState, useEffect } from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import { Target, Calendar, MessageSquare, Users, CheckCircle, Clock } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function MyKPIPage() {
  const supabase = useSupabase();
  const { staff } = useStaffProfile();
  const [kpis, setKpis] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [feedback, setFeedback] = useState('');
  const [selectedKPI, setSelectedKPI] = useState<string | null>(null);

  useEffect(() => {
    if (staff?.id) {
      loadKPIs();
    }
  }, [staff?.id]);

  const loadKPIs = async () => {
    try {
      if (!staff?.id) {
        toast.error('Staff profile not found');
        return;
      }

      // Get all KPIs where staff_id matches or department_id matches staff's departments
      const { data, error } = await supabase
        .from('kpis')
        .select(`
          *,
          department:departments(id, name),
          staff:staff_id(id, name),
          feedback:kpi_feedback(
            id,
            message,
            created_at,
            created_by,
            is_admin
          )
        `)
        .or(
          `staff_id.eq.${staff.id},` +
          `department_id.in.(${staff.departments?.map(d => d.department.id).join(',')})`
        )
        .order('created_at', { ascending: false });

      if (error) throw error;
      setKpis(data || []);
    } catch (error) {
      console.error('Error loading KPIs:', error);
      toast.error('Failed to load KPIs');
    } finally {
      setLoading(false);
    }
  };

  const addFeedback = async (kpiId: string, message: string) => {
    if (!staff?.id) return;

    try {
      // Insert feedback directly
      const { error } = await supabase
        .from('kpi_feedback')
        .insert({
          kpi_id: kpiId,
          message: message,
          created_by: staff.id,
          is_admin: false
        });

      if (error) throw error;

      setFeedback('');
      setSelectedKPI(null);
      await loadKPIs();
      toast.success('Feedback added successfully');
    } catch (error) {
      console.error('Error adding feedback:', error);
      toast.error('Failed to add feedback');
    }
  };

  // Calculate statistics
  const stats = {
    total: kpis.length,
    achieved: kpis.filter(k => k.status === 'Achieved').length,
    pending: kpis.filter(k => k.status === 'Pending').length,
    notAchieved: kpis.filter(k => k.status === 'Not Achieved').length
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center p-6">
        <div className="animate-pulse text-gray-500">Loading KPIs...</div>
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="p-6">
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <Target className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">Profile Not Found</h3>
          <p className="mt-1 text-sm text-gray-500">Unable to load your profile information.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">My KPIs</h1>
        <p className="mt-1 text-sm text-gray-500">Track your Key Performance Indicators</p>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-indigo-100 text-indigo-600">
              <Target className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total KPIs</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.total}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-green-100 text-green-600">
              <CheckCircle className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Achieved</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.achieved}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-yellow-100 text-yellow-600">
              <Clock className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Pending</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.pending}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-red-100 text-red-600">
              <Target className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Not Achieved</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.notAchieved}</p>
            </div>
          </div>
        </div>
      </div>

      {/* KPIs List */}
      <div className="space-y-6">
        {kpis.map((kpi) => (
          <div 
            key={kpi.id} 
            className="bg-white rounded-lg shadow p-6"
          >
            <div className="flex justify-between items-start">
              <div>
                <h3 className="text-lg font-medium text-gray-900">{kpi.title}</h3>
                <div className="mt-2 space-y-1">
                  {kpi.description.split('\n').map((line: string, index: number) => (
                    <p key={index} className="text-gray-700">
                      {line.trim().startsWith('•') ? line : `• ${line}`}
                    </p>
                  ))}
                </div>
                <div className="flex items-center space-x-4 mt-4">
                  <div className="flex items-center text-sm text-gray-500">
                    <Calendar className="h-4 w-4 mr-1" />
                    {new Date(kpi.start_date).toLocaleDateString()} - {new Date(kpi.end_date).toLocaleDateString()}
                  </div>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    kpi.status === 'Achieved' ? 'bg-green-100 text-green-800' :
                    kpi.status === 'Not Achieved' ? 'bg-red-100 text-red-800' :
                    'bg-yellow-100 text-yellow-800'
                  }`}>
                    {kpi.status}
                  </span>
                  <span className="px-2 py-1 text-xs font-medium rounded-full bg-indigo-100 text-indigo-800">
                    {kpi.period}
                  </span>
                </div>
                <div className="mt-2 text-sm text-gray-600">
                  <span className="font-medium">Assigned to: </span>
                  {kpi.staff ? (
                    <span>Individual - {kpi.staff.name}</span>
                  ) : kpi.department ? (
                    <span>Department - {kpi.department.name}</span>
                  ) : (
                    <span>Not assigned</span>
                  )}
                </div>
              </div>
            </div>

            {/* Feedback Section */}
            <div className="mt-4 border-t pt-4">
              <div className="space-y-4">
                {kpi.feedback?.map((item: any) => (
                  <div
                    key={item.id}
                    className={`p-3 rounded-lg ${
                      item.is_admin ? 'bg-blue-50 ml-8' : 'bg-gray-50 mr-8'
                    }`}
                  >
                    <p className="text-sm text-gray-600">{item.message}</p>
                    <p className="text-xs text-gray-500 mt-1">
                      {new Date(item.created_at).toLocaleDateString()}
                    </p>
                  </div>
                ))}
              </div>
              <div className="mt-4 flex space-x-2">
                <input
                  type="text"
                  value={selectedKPI === kpi.id ? feedback : ''}
                  onChange={(e) => {
                    setSelectedKPI(kpi.id);
                    setFeedback(e.target.value);
                  }}
                  placeholder="Add feedback or request clarification..."
                  className="flex-1 rounded-md border border-gray-300 px-3 py-2 text-sm"
                />
                <button
                  onClick={() => {
                    if (feedback.trim()) {
                      addFeedback(kpi.id, feedback);
                    }
                  }}
                  className="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700"
                >
                  <MessageSquare className="h-4 w-4 mr-1" />
                  Send
                </button>
              </div>
            </div>
          </div>
        ))}
        {kpis.length === 0 && (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Target className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No KPIs Found</h3>
            <p className="mt-1 text-sm text-gray-500">
              You don't have any KPIs assigned to you or your department yet.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}