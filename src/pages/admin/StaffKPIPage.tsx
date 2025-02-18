import React, { useState, useEffect } from 'react';
import { Plus, Target, Calendar, MessageSquare, Users, CheckCircle, Clock, Trash2, Search, Filter } from 'lucide-react';
import { useStaff } from '../../hooks/useStaff';
import { KPIType } from '../../types/kpi';
import { useAuth } from '../../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../providers/SupabaseProvider';

export default function StaffKPIPage() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const { staff } = useStaff();
  const [kpis, setKpis] = useState<KPIType[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedPeriod, setSelectedPeriod] = useState<string>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');
  const [selectedAssignment, setSelectedAssignment] = useState<string>('all');
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
    if (user?.email) {
      loadKPIs();
    }
  }, [user?.email]);

  // Function to get dates for a given period
  const getDateRangeForPeriod = (period: string) => {
    const currentYear = new Date().getFullYear();
    let startDate = '';
    let endDate = '';

    switch (period) {
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
      default:
        startDate = '';
        endDate = '';
    }

    return { startDate, endDate };
  };

  // Update dates when period changes
  const handlePeriodChange = (period: string) => {
    const { startDate, endDate } = getDateRangeForPeriod(period);
    setFormData({
      ...formData,
      period,
      start_date: startDate,
      end_date: endDate
    });
  };

  const loadKPIs = async () => {
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
      if (!staffData?.company_id) {
        toast.error('Company not found');
        return;
      }

      // Get KPIs directly from the kpis table with proper joins
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
        .eq('company_id', staffData.company_id)
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
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
      if (!staffData?.company_id) {
        toast.error('Company not found');
        return;
      }

      if (formData.assignTo === 'staff' && !formData.staff_id) {
        toast.error('Please select a staff member');
        return;
      }

      if (formData.assignTo === 'department' && !formData.department_id) {
        toast.error('Please select a department');
        return;
      }

      // Convert description to bullet points if it contains newlines
      const description = formData.description
        .split('\n')
        .filter(line => line.trim())
        .map(line => line.trim().startsWith('•') ? line : `• ${line}`)
        .join('\n');

      const kpiData = {
        title: formData.title,
        description,
        period: formData.period,
        start_date: formData.start_date,
        end_date: formData.end_date,
        department_id: formData.assignTo === 'department' ? formData.department_id : null,
        staff_id: formData.assignTo === 'staff' ? formData.staff_id : null,
        company_id: staffData.company_id,
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

  const handleDelete = async (kpi: KPIType) => {
    if (!window.confirm('Are you sure you want to delete this KPI?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('kpis')
        .delete()
        .eq('id', kpi.id);

      if (error) throw error;

      toast.success('KPI deleted successfully');
      loadKPIs();
    } catch (error) {
      console.error('Error deleting KPI:', error);
      toast.error('Failed to delete KPI');
    }
  };

  // Filter KPIs based on search term and filters
  const filteredKpis = kpis.filter(kpi => {
    const matchesSearch = 
      kpi.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      kpi.description.toLowerCase().includes(searchTerm.toLowerCase());

    const matchesPeriod = selectedPeriod === 'all' || kpi.period === selectedPeriod;
    
    const matchesStatus = selectedStatus === 'all' || kpi.status === selectedStatus;
    
    const matchesAssignment = selectedAssignment === 'all' || 
      (selectedAssignment === 'department' && kpi.department_id) ||
      (selectedAssignment === 'individual' && kpi.staff_id);

    return matchesSearch && matchesPeriod && matchesStatus && matchesAssignment;
  });

  // Calculate statistics for filtered KPIs
  const stats = {
    total: filteredKpis.length,
    achieved: filteredKpis.filter(k => k.status === 'Achieved').length,
    pending: filteredKpis.filter(k => k.status === 'Pending').length,
    notAchieved: filteredKpis.filter(k => k.status === 'Not Achieved').length
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
          onClick={() => {
            const { startDate, endDate } = getDateRangeForPeriod('Q1');
            setFormData(prev => ({
              ...prev,
              start_date: startDate,
              end_date: endDate
            }));
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create KPI
        </button>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
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

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
          {/* Search */}
          <div className="lg:col-span-2">
            <div className="relative">
              <Search className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search by title or description..."
                className="pl-10 w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>

          {/* Period Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
            >
              <option value="all">All Periods</option>
              <option value="Q1">Q1</option>
              <option value="Q2">Q2</option>
              <option value="Q3">Q3</option>
              <option value="Q4">Q4</option>
              <option value="yearly">Yearly</option>
            </select>
          </div>

          {/* Status Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
            >
              <option value="all">All Status</option>
              <option value="Pending">Pending</option>
              <option value="Achieved">Achieved</option>
              <option value="Not Achieved">Not Achieved</option>
            </select>
          </div>

          {/* Assignment Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedAssignment}
              onChange={(e) => setSelectedAssignment(e.target.value)}
            >
              <option value="all">All Assignments</option>
              <option value="department">Department</option>
              <option value="individual">Individual</option>
            </select>
          </div>
        </div>
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-2xl w-full">
            <h2 className="text-xl font-bold">Create New KPI</h2>
            <form onSubmit={handleSubmit} className="space-y-6 mt-4">
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
                <p className="text-sm text-gray-500 mb-1">Enter each point on a new line. They will be automatically formatted as bullet points.</p>
                <textarea
                  required
                  rows={5}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder="Enter each KPI requirement on a new line:
Complete quarterly sales targets
Improve customer satisfaction ratings
Reduce response time to client inquiries"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Period</label>
                <select
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.period}
                  onChange={(e) => handlePeriodChange(e.target.value)}
                >
                  <option value="Q1">Q1 (Jan-Mar)</option>
                  <option value="Q2">Q2 (Apr-Jun)</option>
                  <option value="Q3">Q3 (Jul-Sep)</option>
                  <option value="Q4">Q4 (Oct-Dec)</option>
                  <option value="yearly">Yearly</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700">Start Date</label>
                  <input
                    type="date"
                    required
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 bg-gray-100"
                    value={formData.start_date}
                    readOnly
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700">End Date</label>
                  <input
                    type="date"
                    required
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 bg-gray-100"
                    value={formData.end_date}
                    readOnly
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Assign To</label>
                <div className="mt-1 grid grid-cols-2 gap-4">
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, assignTo: 'department', staff_id: '' })}
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
                    onClick={() => setFormData({ ...formData, assignTo: 'staff', department_id: '' })}
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
                    <option value="">Select a department</option>
                    {staff.reduce((departments: any[], member) => {
                      member.departments?.forEach(dept => {
                        if (dept.is_primary && !departments.find(d => d.id === dept.department.id)) {
                          departments.push(dept.department);
                        }
                      });
                      return departments;
                    }, []).map((dept) => (
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
                    {staff.map((member) => (
                      <option key={member.id} value={member.id}>
                        {member.name} - {member.departments?.find(d => d.is_primary)?.department.name}
                      </option>
                    ))}
                  </select>
                </div>
              )}

              <div className="flex justify-end space-x-3">
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
        {filteredKpis.map((kpi) => (
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
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => handleDelete(kpi)}
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
        {filteredKpis.length === 0 && (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Target className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No KPIs Found</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm || selectedPeriod !== 'all' || selectedStatus !== 'all' || selectedAssignment !== 'all'
                ? 'No KPIs match your search criteria'
                : 'Get started by creating a new KPI'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}