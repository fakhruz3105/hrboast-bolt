import React, { useState, useEffect } from 'react';
import { Plus, Eye, Edit, Trash2, Link as LinkIcon } from 'lucide-react';
import { useStaffLevels } from '../../../hooks/useStaffLevels';
import { useDepartments } from '../../../hooks/useDepartments';
import { useAuth } from '../../../contexts/AuthContext';
import CreateFormRequest from '../../../components/admin/hr-form/employee/CreateFormRequest';
import ResponseViewer from '../../../components/admin/hr-form/employee/ResponseViewer';
import EditFormRequest from '../../../components/admin/hr-form/employee/EditFormRequest';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function EmployeeFormPage() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const { levels } = useStaffLevels();
  const { departments } = useDepartments();
  const [showForm, setShowForm] = useState(false);
  const [formRequests, setFormRequests] = useState<any[]>([]);
  const [selectedResponse, setSelectedResponse] = useState<any>(null);
  const [editingRequest, setEditingRequest] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user?.email) {
      loadFormRequests();
    }
  }, [user?.email]);

  const loadFormRequests = async () => {
    try {
      // First get the company ID for the current user
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (staffError) throw staffError;
      if (!staffData?.company_id) {
        toast.error('Company not found. Please contact administrator.');
        return;
      }

      const { data, error } = await supabase
        .from('employee_form_requests')
        .select(`
          *,
          department:departments(name),
          level:staff_levels(name),
          responses:employee_form_responses(
            id,
            personal_info,
            education_history,
            employment_history,
            emergency_contacts
          )
        `)
        .eq('company_id', staffData.company_id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setFormRequests(data || []);
    } catch (error) {
      console.error('Error loading form requests:', error);
      toast.error('Failed to load form requests');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateForm = async (formData: any) => {
    try {
      // Get company ID for current user
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (staffError) throw staffError;
      if (!staffData?.company_id) {
        toast.error('Company not found. Please contact administrator.');
        return;
      }

      // Create form request with a unique ID
      const formId = crypto.randomUUID();
      const { data: requestData, error: requestError } = await supabase
        .from('employee_form_requests')
        .insert([{
          staff_name: formData.name,
          email: formData.email,
          phone_number: formData.phone,
          department_id: formData.department_id,
          level_id: formData.level_id,
          company_id: staffData.company_id,
          form_link: formId,
          expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
        }])
        .select()
        .single();

      if (requestError) throw requestError;

      // Create HR letter
      const { error: letterError } = await supabase
        .from('hr_letters')
        .insert([{
          title: 'Employee Information Form',
          type: 'interview',
          content: {
            type: 'employee',
            form_request_id: requestData.id,
            status: 'pending'
          },
          status: 'pending',
          issued_date: new Date().toISOString()
        }]);

      if (letterError) throw letterError;
      
      await loadFormRequests();
      setShowForm(false);
      toast.success('Form created successfully');
    } catch (error) {
      console.error('Error creating form:', error);
      toast.error('Failed to create form');
    }
  };

  const handleEditForm = async (formData: any) => {
    try {
      const { error } = await supabase
        .from('employee_form_requests')
        .update({
          staff_name: formData.name,
          email: formData.email,
          phone_number: formData.phone,
          department_id: formData.department_id,
          level_id: formData.level_id
        })
        .eq('id', editingRequest.id);

      if (error) throw error;

      toast.success('Form updated successfully');
      setEditingRequest(null);
      await loadFormRequests();
    } catch (error) {
      console.error('Error updating form:', error);
      toast.error('Failed to update form');
    }
  };

  const handleViewResponse = async (requestId: string) => {
    try {
      const { data, error } = await supabase
        .from('employee_form_responses')
        .select('*')
        .eq('request_id', requestId)
        .single();

      if (error) throw error;
      setSelectedResponse(data);
    } catch (error) {
      console.error('Error loading response:', error);
      toast.error('Failed to load response');
    }
  };

  const handleDeleteRequest = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this form request?')) return;

    try {
      const { error } = await supabase
        .from('employee_form_requests')
        .delete()
        .eq('id', id);

      if (error) throw error;
      
      setFormRequests(prev => prev.filter(request => request.id !== id));
      toast.success('Form request deleted successfully');
    } catch (error) {
      console.error('Error deleting form request:', error);
      toast.error('Failed to delete form request');
    }
  };

  const handleCopyLink = (formId: string) => {
    const baseUrl = window.location.origin;
    const formUrl = `${baseUrl}/employee-form/${formId}`;
    navigator.clipboard.writeText(formUrl);
    toast.success('Form link copied to clipboard');
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
          <h1 className="text-2xl font-bold text-gray-900">Employee Forms</h1>
          <p className="text-gray-600 mt-1">Create and manage employee information forms</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create Employee Form
        </button>
      </div>

      {showForm && (
        <CreateFormRequest
          departments={departments}
          levels={levels}
          onSubmit={handleCreateForm}
          onClose={() => setShowForm(false)}
        />
      )}

      {editingRequest && (
        <EditFormRequest
          request={editingRequest}
          departments={departments}
          levels={levels}
          onSubmit={handleEditForm}
          onClose={() => setEditingRequest(null)}
        />
      )}

      <div className="bg-white rounded-lg shadow">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Level</th>
                <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {formRequests.map((request) => (
                <tr key={request.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{request.staff_name}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{request.email}</div>
                    <div className="text-sm text-gray-500">{request.phone_number}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {request.department?.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {request.level?.name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                      request.status === 'completed'
                        ? 'bg-green-100 text-green-800'
                        : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {request.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex justify-end space-x-2">
                      {request.status === 'completed' ? (
                        <button
                          onClick={() => handleViewResponse(request.id)}
                          className="text-indigo-600 hover:text-indigo-900"
                          title="View Response"
                        >
                          <Eye className="h-4 w-4" />
                        </button>
                      ) : (
                        <>
                          <button
                            onClick={() => setEditingRequest(request)}
                            className="text-blue-600 hover:text-blue-900"
                            title="Edit Form"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleCopyLink(request.form_link)}
                            className="text-indigo-600 hover:text-indigo-900"
                            title="Copy Form Link"
                          >
                            <LinkIcon className="h-4 w-4" />
                          </button>
                        </>
                      )}
                      <button
                        onClick={() => handleDeleteRequest(request.id)}
                        className="text-red-600 hover:text-red-900"
                        title="Delete Form"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
              {formRequests.length === 0 && (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center text-sm text-gray-500">
                    No form requests found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {selectedResponse && (
        <ResponseViewer
          response={selectedResponse}
          onClose={() => setSelectedResponse(null)}
        />
      )}
    </div>
  );
}