import React, { useState, useEffect } from 'react';
import { Plus, Target, Calendar, MessageSquare, AlertCircle, CheckCircle, Clock, Trash2 } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../providers/SupabaseProvider';

type KPI = {
  id: string;
  title: string;
  description: string;
  period: string;
  start_date: string;
  end_date: string;
  department_id: string | null;
  staff_id: string | null;
  status: 'Pending' | 'Achieved' | 'Not Achieved';
  admin_comment?: string;
  created_at: string;
  feedback?: Array<{
    id: string;
    message: string;
    created_at: string;
    created_by: string;
    is_admin: boolean;
  }>;
};

type Department = {
  id: string;
  name: string;
};

type Staff = {
  id: string;
  name: string;
  department?: {
    name: string;
  };
};

export default function StaffKPIPage() {
  const supabase = useSupabase();
  const [kpis, setKpis] = useState<KPI[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [staffMembers, setStaffMembers] = useState<Staff[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    period: 'Q1',
    start_date: '',
    end_date: '',
    assignTo: 'department',
    department_id: '',
    staff_id: ''
  });

  useEffect(() => {
    Promise.all([
      loadKPIs(),
      loadDepartments(),
      loadStaff()
    ]);
  }, []);

  const loadKPIs = async () => {
    try {
      const { data, error } = await supabase
        .from('kpis')
        .select(`
          *,
          department:departments(name),
          staff:staff_id(name),
          feedback:kpi_feedback(*)
        `)
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
        .select('id, name')
        .order('name');

      if (error) throw error;
      setDepartments(data || []);
    } catch (error) {
      console.error('Error loading departments:', error);
      toast.error('Failed to load departments');
    }
  };

  const loadStaff = async () => {
    try {
      const { data, error } = await supabase
        .from('staff')
        .select(`
          id,
          name,
          departments:staff_departments!inner(
            is_primary,
            department:departments!inner(name)
          )
        `)
        .eq('status', 'permanent')
        .eq('staff_departments.is_primary', true);

      if (error) throw error;
      setStaffMembers(data || []);
    } catch (error) {
      console.error('Error loading staff:', error);
      toast.error('Failed to load staff members');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      // Calculate dates based on period
      let startDate = formData.start_date;
      let endDate = formData.end_date;

      const currentYear = new Date().getFullYear();

      switch (formData.period) {
        case 'Q1':
          startDate = `${currentYear}-01-01`;
          endDate = `${currentYear}-03-31`;
          break;
        case 'Q2':
          startDate = `${currentYear}-04-01`;
          endDate = `${currentYear}-06-30`;
          break;
        case 'Q3':
          startDate = `${currentYear}-07-01`;
          endDate = `${currentYear}-09-30`;
          break;
        case 'Q4':
          startDate = `${currentYear}-10-01`;
          endDate = `${currentYear}-12-31`;
          break;
        case 'yearly':
          startDate = `${currentYear}-01-01`;
          endDate = `${currentYear}-12-31`;
          break;
      }

      if (!formData.department_id && !formData.staff_id) {
        toast.error('Please select a department or staff member');
        return;
      }

      const kpiData = {
        title: formData.title,
        description: formData.description,
        period: formData.period,
        start_date: startDate,
        end_date: endDate,
        department_id: formData.assignTo === 'department' ? formData.department_id : null,
        staff_id: formData.assignTo === 'staff' ? formData.staff_id : null,
        status: 'Pending'
      };

      const { error } = await supabase
        .from('kpis')
        .insert([kpiData]);

      if (error) throw error;

      toast.success('KPI created successfully');
      setShowForm(false);
      setFormData({
        title: '',
        description: '',
        period: 'Q1',
        start_date: '',
        end_date: '',
        assignTo: 'department',
        department_id: '',
        staff_id: ''
      });
      loadKPIs();
    } catch (error) {
      console.error('Error creating KPI:', error);
      toast.error('Failed to create KPI');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this KPI?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('kpis')
        .delete()
        .eq('id', id);

      if (error) throw error;

      toast.success('KPI deleted successfully');
      loadKPIs();
    } catch (error) {
      console.error('Error deleting KPI:', error);
      toast.error('Failed to delete KPI');
    }
  };

  if (loading) {
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
          <h1 className="text-2xl font-bold text-gray-900">Staff KPI</h1>
          <p className="text-gray-600 mt-1">Manage Key Performance Indicators</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create KPI
        </button>
      </div>

      {/* KPI Form Modal */}
      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-2xl w-full">
            <h2 className="text-xl font-bold text-gray-900 mb-4">Create New KPI</h2>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700">Title</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  required
                  rows={3}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Period</label>
                <select
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.period}
                  onChange={(e) => setFormData({ ...formData, period: e.target.value })}
                >
                  <option value="Q1">Q1 (Jan-Mar)</option>
                  <option value="Q2">Q2 (Apr-Jun)</option>
                  <option value="Q3">Q3 (Jul-Sep)</option>
                  <option value="Q4">Q4 (Oct-Dec)</option>
                  <option value="yearly">Yearly</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Assign To</label>
                <div className="mt-1 grid grid-cols-2 gap-4">
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, assignTo: 'department' })}
                    className={`p-4 text-center border rounded-lg ${
                      formData.assignTo === 'department'
                        ? 'border-indigo-500 bg-indigo-50 text-indigo-700'
                        : 'border-gray-200 hover:border-indigo-200 text-gray-700'
                    }`}
                  >
                    Department
                  </button>
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, assignTo: 'staff' })}
                    className={`p-4 text-center border rounded-lg ${
                      formData.assignTo === 'staff'
                        ? 'border-indigo-500 bg-indigo-50 text-indigo-700'
                        : 'border-gray-200 hover:border-indigo-200 text-gray-700'
                    }`}
                  >
                    Individual Staff
                  </button>
                </div>
              </div>

              {formData.assignTo === 'department' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700">Select Department</label>
                  <select
                    required
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                    value={formData.department_id}
                    onChange={(e) => setFormData({ ...formData, department_id: e.target.value })}
                  >
                    <option value="">Select department</option>
                    {departments.map((dept) => (
                      <option key={dept.id} value={dept.id}>{dept.name}</option>
                    ))}
                  </select>
                </div>
              )}

              {formData.assignTo === 'staff' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700">Select Staff</label>
                  <select
                    required
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                    value={formData.staff_id}
                    onChange={(e) => setFormData({ ...formData, staff_id: e.target.value })}
                  >
                    <option value="">Select staff member</option>
                    {staffMembers.map((member) => (
                      <option key={member.id} value={member.id}>
                        {member.name} - {member.departments?.[0]?.department?.name}
                      </option>
                    ))}
                  </select>
                </div>
              )}

              <div className="flex justify-end space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => setShowForm(false)}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                >
                  Create KPI
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* KPI List */}
      <div className="space-y-6">
        {kpis.map((kpi) => (
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
                <div className="mt-2 text-sm text-gray-600">
                  <span className="font-medium">Assigned to: </span>
                  {kpi.staff_id ? (
                    <span>Individual - {kpi.staff?.name}</span>
                  ) : (
                    <span>Department - {kpi.department?.name}</span>
                  )}
                </div>
              </div>
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => handleDelete(kpi.id)}
                  className="text-red-600 hover:text-red-900 p-2 rounded-full hover:bg-red-50 transition-colors"
                  title="Delete KPI"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>
            </div>

            {/* Feedback Section */}
            {kpi.feedback && kpi.feedback.length > 0 && (
              <div className="mt-4 border-t pt-4">
                <h4 className="text-sm font-medium text-gray-900 mb-2">Feedback & Updates</h4>
                <div className="space-y-3">
                  {kpi.feedback.map((item) => (
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
              </div>
            )}
          </div>
        ))}
        {kpis.length === 0 && (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Target className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No KPIs</h3>
            <p className="mt-1 text-sm text-gray-500">Get started by creating a new KPI.</p>
          </div>
        )}
      </div>
    </div>
  );
}