import React, { useState, useEffect } from 'react';
import { Plus, Link as LinkIcon, Eye, Pencil, Trash2 } from 'lucide-react';
import { supabase } from '../../../lib/supabase';
import ResponseViewer from '../../../components/admin/interviews/ResponseViewer';

type FormLink = {
  id: string;
  staff_name: string;
  email: string;
  form_link: string;
  status: string;
  responses?: any[];
};

export default function StaffInterviewPage() {
  const [formLinks, setFormLinks] = useState<FormLink[]>([]);
  const [showCreateForm, setShowCreateForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    staff_name: '',
    email: ''
  });
  const [selectedResponse, setSelectedResponse] = useState<any>(null);
  const [editingForm, setEditingForm] = useState<FormLink | null>(null);

  useEffect(() => {
    loadFormLinks();
  }, []);

  const loadFormLinks = async () => {
    try {
      const { data, error } = await supabase
        .from('staff_interviews')
        .select(`
          *,
          responses:staff_interview_forms(*)
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setFormLinks(data || []);
    } catch (error) {
      console.error('Error loading form links:', error);
      alert('Failed to load form links');
    }
  };

  const createForm = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setLoading(true);
      const { error } = await supabase
        .from('staff_interviews')
        .insert([{
          staff_name: formData.staff_name,
          email: formData.email,
          status: 'pending',
          expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
        }]);

      if (error) throw error;

      setShowCreateForm(false);
      setFormData({ staff_name: '', email: '' });
      await loadFormLinks();
    } catch (error) {
      console.error('Error creating form:', error);
      alert('Failed to create form');
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = async (form: FormLink) => {
    setEditingForm(form);
    setFormData({
      staff_name: form.staff_name,
      email: form.email
    });
    setShowCreateForm(true);
  };

  const updateForm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingForm) return;

    try {
      setLoading(true);
      const { error } = await supabase
        .from('staff_interviews')
        .update({
          staff_name: formData.staff_name,
          email: formData.email
        })
        .eq('id', editingForm.id);

      if (error) throw error;

      setShowCreateForm(false);
      setEditingForm(null);
      setFormData({ staff_name: '', email: '' });
      await loadFormLinks();
    } catch (error) {
      console.error('Error updating form:', error);
      alert('Failed to update form');
    } finally {
      setLoading(false);
    }
  };

  const deleteFormLink = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this form?')) return;

    try {
      const { error } = await supabase
        .from('staff_interviews')
        .delete()
        .eq('id', id);

      if (error) throw error;
      await loadFormLinks();
    } catch (error) {
      console.error('Error deleting form:', error);
      alert('Failed to delete form');
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Employee Forms</h1>
          <p className="text-gray-600 mt-1">Create and manage employee information forms</p>
        </div>
        <button
          onClick={() => {
            setEditingForm(null);
            setFormData({ staff_name: '', email: '' });
            setShowCreateForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create Form
        </button>
      </div>

      {showCreateForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h2 className="text-lg font-semibold mb-4">
              {editingForm ? 'Edit Employee Form' : 'Create Employee Form'}
            </h2>
            <form onSubmit={editingForm ? updateForm : createForm} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Staff Name</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.staff_name}
                  onChange={(e) => setFormData({ ...formData, staff_name: e.target.value })}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Email</label>
                <input
                  type="email"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
              </div>
              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowCreateForm(false);
                    setEditingForm(null);
                    setFormData({ staff_name: '', email: '' });
                  }}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                  disabled={loading}
                >
                  {loading ? 'Saving...' : editingForm ? 'Update Form' : 'Create Form'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff Name</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {formLinks.map((form) => (
              <tr key={form.id}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {form.staff_name}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {form.email}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    form.status === 'completed'
                      ? 'bg-green-100 text-green-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {form.status}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                  {form.responses?.length > 0 && (
                    <>
                      <button
                        onClick={() => setSelectedResponse(form.responses[0])}
                        className="text-indigo-600 hover:text-indigo-900"
                        title="View Response"
                      >
                        <Eye className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleEdit(form)}
                        className="text-blue-600 hover:text-blue-900"
                        title="Edit Form"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                    </>
                  )}
                  <button
                    onClick={() => navigator.clipboard.writeText(`${window.location.origin}/staff-form/${form.id}`)}
                    className="text-blue-600 hover:text-blue-900"
                    title="Copy Form Link"
                  >
                    <LinkIcon className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => deleteFormLink(form.id)}
                    className="text-red-600 hover:text-red-900"
                    title="Delete Form"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
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