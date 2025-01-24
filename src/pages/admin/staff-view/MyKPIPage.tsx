import React, { useState, useEffect } from 'react';
import { Target, Calendar, MessageSquare, Users, CheckCircle, Clock } from 'lucide-react';
import { supabase } from '../../../lib/supabase';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import { toast } from 'react-hot-toast';

type KPI = {
  id: string;
  title: string;
  description: string;
  period: string;
  start_date: string;
  end_date: string;
  status: 'Pending' | 'Achieved' | 'Not Achieved';
  admin_comment?: string;
  department_id?: string;
  staff_id?: string;
  feedback?: Array<{
    id: string;
    message: string;
    created_at: string;
    created_by: string;
    is_admin: boolean;
  }>;
};

export default function MyKPIPage() {
  const { staff } = useStaffProfile();
  const [kpis, setKpis] = useState<KPI[]>([]);
  const [loading, setLoading] = useState(true);
  const [feedback, setFeedback] = useState('');
  const [selectedKPI, setSelectedKPI] = useState<string | null>(null);
  const [departmentNames, setDepartmentNames] = useState<Record<string, string>>({});

  useEffect(() => {
    if (staff?.id) {
      loadKPIs();
      loadDepartments();
    }
  }, [staff?.id]);

  const loadKPIs = async () => {
    try {
      // Get staff's department IDs
      const { data: deptData, error: deptError } = await supabase
        .from('staff_departments')
        .select('department_id')
        .eq('staff_id', staff!.id);

      if (deptError) throw deptError;

      const departmentIds = deptData.map(d => d.department_id);

      // Get KPIs assigned to staff directly or to their departments
      const { data, error } = await supabase
        .from('kpis')
        .select(`
          *,
          feedback:kpi_feedback(*)
        `)
        .or(
          `staff_id.eq.${staff!.id},and(department_id.in.(${departmentIds.join(',')}),staff_id.is.null)`
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

  const loadDepartments = async () => {
    try {
      const { data, error } = await supabase
        .from('departments')
        .select('id, name');

      if (error) throw error;

      const deptMap: Record<string, string> = {};
      data?.forEach(dept => {
        deptMap[dept.id] = dept.name;
      });
      setDepartmentNames(deptMap);
    } catch (error) {
      console.error('Error loading departments:', error);
    }
  };

  const addFeedback = async (kpiId: string, message: string) => {
    if (!staff?.id) return;

    try {
      const { error } = await supabase
        .from('kpi_feedback')
        .insert([{
          kpi_id: kpiId,
          message,
          is_admin: false,
          created_by: staff.id
        }]);

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

  // Separate KPIs into personal and department
  const personalKPIs = kpis.filter(kpi => kpi.staff_id === staff?.id);
  const departmentKPIs = kpis.filter(kpi => kpi.department_id && !kpi.staff_id);

  // Calculate statistics
  const stats = {
    total: kpis.length,
    achieved: kpis.filter(k => k.status === 'Achieved').length,
    pending: kpis.filter(k => k.status === 'Pending').length,
    notAchieved: kpis.filter(k => k.status === 'Not Achieved').length
  };

  const renderKPICard = (kpi: KPI) => (
    <div key={kpi.id} className="bg-white rounded-lg shadow p-6">
      <div className="flex justify-between items-start">
        <div>
          <h3 className="text-lg font-medium text-gray-900">{kpi.title}</h3>
          <p className="mt-1 text-sm text-gray-500">{kpi.description}</p>
          <div className="flex items-center space-x-4 mt-2">
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
          <div className="mt-2 flex items-center text-sm text-gray-500">
            <Users className="h-4 w-4 mr-1" />
            <span>
              Assigned to: {kpi.staff_id ? 'Individual Staff' : 
                `Department - ${departmentNames[kpi.department_id || '']}`}
            </span>
          </div>
        </div>
      </div>
      
      {/* Admin Comment */}
      {kpi.admin_comment && (
        <div className="mt-4 bg-blue-50 p-4 rounded-lg">
          <p className="text-sm font-medium text-blue-900">Admin Comment:</p>
          <p className="mt-1 text-sm text-blue-800">{kpi.admin_comment}</p>
        </div>
      )}

      {/* Feedback Section */}
      <div className="mt-4 border-t pt-4">
        <div className="space-y-4">
          {kpi.feedback?.map((item) => (
            <div
              key={item.id}
              className={`p-3 rounded-lg ${
                item.is_admin ? 'bg-blue-50 ml-8' : 'bg-gray-50 mr-8'
              }`}
            >
              <p className="text-sm text-gray-600">{item.message}</p>
              <p className="text-xs text-gray-500 mt-1">
                {new Date(item.created_at).toLocaleString()}
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
  );

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

      {/* Personal KPIs Section */}
      <div className="mb-8">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">
          My Personal KPIs
          <span className="ml-2 text-sm font-normal text-gray-500">
            ({personalKPIs.length} KPIs assigned to you)
          </span>
        </h2>
        <div className="space-y-4">
          {personalKPIs.length > 0 ? (
            personalKPIs.map(renderKPICard)
          ) : (
            <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-200">
              <p className="text-gray-500">No personal KPIs assigned</p>
            </div>
          )}
        </div>
      </div>

      {/* Department KPIs Section */}
      <div>
        <h2 className="text-xl font-semibold text-gray-900 mb-4">
          My Department KPIs
          <span className="ml-2 text-sm font-normal text-gray-500">
            ({departmentKPIs.length} KPIs assigned to your department)
          </span>
        </h2>
        <div className="space-y-4">
          {departmentKPIs.length > 0 ? (
            departmentKPIs.map(renderKPICard)
          ) : (
            <div className="text-center py-8 bg-gray-50 rounded-lg border-2 border-dashed border-gray-200">
              <p className="text-gray-500">No department KPIs assigned</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}