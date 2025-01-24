import React, { useState, useEffect } from 'react';
import { Plus, Search, Filter, Medal, Gift, TrendingUp, DollarSign, Eye, Edit, Trash2, Download } from 'lucide-react';
import { supabase } from '../../../lib/supabase';
import { useDepartments } from '../../../hooks/useDepartments';
import { useStaff } from '../../../hooks/useStaff';
import { MemoType } from '../../../types/memo';
import { useAuth } from '../../../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { generateMemoPDF } from '../../../utils/memoPDF';

export default function MemoPage() {
  const { user } = useAuth();
  const { departments } = useDepartments();
  const { staff } = useStaff();
  const [memos, setMemos] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    title: '',
    type: 'recognition' as MemoType,
    content: '',
    recipient: 'all',
    department_id: '',
    staff_ids: [] as string[]
  });

  useEffect(() => {
    if (user?.email) {
      loadMemos();
    }
  }, [user?.email]);

  const loadMemos = async () => {
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

      const { data, error } = await supabase.rpc('get_staff_memo_list', {
        p_staff_id: staffData.id
      });

      if (error) throw error;
      setMemos(data || []);
    } catch (error) {
      console.error('Error loading memos:', error);
      toast.error('Failed to load memos');
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

      if (formData.recipient === 'staff' && formData.staff_ids.length === 0) {
        toast.error('Please select at least one staff member');
        return;
      }

      if (formData.recipient === 'department' && !formData.department_id) {
        toast.error('Please select a department');
        return;
      }

      const memoData = {
        title: formData.title,
        type: formData.type,
        content: formData.content,
        department_id: formData.recipient === 'department' ? formData.department_id : null,
        staff_id: formData.recipient === 'staff' ? formData.staff_ids[0] : null,
        company_id: staffData.company_id
      };

      if (formData.recipient === 'staff' && formData.staff_ids.length > 1) {
        // Create individual memos for each selected staff
        const promises = formData.staff_ids.map(staffId =>
          supabase
            .from('memos')
            .insert({
              ...memoData,
              staff_id: staffId
            })
        );

        await Promise.all(promises);
      } else {
        // Create single memo for department or all staff
        await supabase
          .from('memos')
          .insert([memoData]);
      }

      toast.success('Memo created successfully');
      setShowForm(false);
      setFormData({
        title: '',
        type: 'recognition',
        content: '',
        recipient: 'all',
        department_id: '',
        staff_ids: []
      });
      loadMemos();
    } catch (error) {
      console.error('Error creating memo:', error);
      toast.error('Failed to create memo');
    }
  };

  const handleDownload = async (memo: any) => {
    try {
      generateMemoPDF(memo);
      toast.success('Memo downloaded successfully');
    } catch (error) {
      console.error('Error downloading memo:', error);
      toast.error('Failed to download memo');
    }
  };

  const handleDelete = async (memo: any) => {
    if (!window.confirm('Are you sure you want to delete this memo?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('memos')
        .delete()
        .eq('id', memo.id);

      if (error) throw error;

      toast.success('Memo deleted successfully');
      loadMemos();
    } catch (error) {
      console.error('Error deleting memo:', error);
      toast.error('Failed to delete memo');
    }
  };

  const getMemoTypeIcon = (type: string) => {
    switch (type) {
      case 'recognition':
        return <Medal className="h-5 w-5" />;
      case 'rewards':
        return <Gift className="h-5 w-5" />;
      case 'bonus':
        return <TrendingUp className="h-5 w-5" />;
      case 'salary_increment':
        return <DollarSign className="h-5 w-5" />;
      default:
        return <Medal className="h-5 w-5" />;
    }
  };

  const getMemoTypeColor = (type: string) => {
    switch (type) {
      case 'recognition':
        return 'bg-purple-100 text-purple-800';
      case 'rewards':
        return 'bg-green-100 text-green-800';
      case 'bonus':
        return 'bg-blue-100 text-blue-800';
      case 'salary_increment':
        return 'bg-amber-100 text-amber-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getMemoTypeLabel = (type: string) => {
    switch (type) {
      case 'recognition':
        return 'Recognition';
      case 'rewards':
        return 'Rewards';
      case 'bonus':
        return 'Bonus Eligible';
      case 'salary_increment':
        return 'Salary Increment';
      default:
        return type;
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
          <h1 className="text-2xl font-bold text-gray-900">Achievement Memos</h1>
          <p className="text-gray-600 mt-1">Create and manage achievement memos</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create Achievement Memo
        </button>
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg shadow-lg p-6 max-w-2xl w-full mx-4">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">Create Achievement Memo</h2>
              <button 
                onClick={() => setShowForm(false)} 
                className="text-gray-500 hover:text-gray-700"
              >
                ×
              </button>
            </div>
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
                <label className="block text-sm font-medium text-gray-700">Type</label>
                <select
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.type}
                  onChange={(e) => setFormData({ ...formData, type: e.target.value as MemoType })}
                >
                  <option value="recognition">Recognition</option>
                  <option value="rewards">Rewards</option>
                  <option value="bonus">Bonus</option>
                  <option value="salary_increment">Salary Increment</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Content</label>
                <textarea
                  required
                  rows={4}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.content}
                  onChange={(e) => setFormData({ ...formData, content: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Recipient</label>
                <select
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.recipient}
                  onChange={(e) => setFormData({ ...formData, recipient: e.target.value })}
                >
                  <option value="all">All Staff</option>
                  <option value="department">Specific Department</option>
                  <option value="staff">Specific Staff</option>
                </select>
              </div>

              {formData.recipient === 'department' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700">Department</label>
                  <select
                    required
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                    value={formData.department_id}
                    onChange={(e) => setFormData({ ...formData, department_id: e.target.value })}
                  >
                    <option value="">Select Department</option>
                    {departments.map((dept) => (
                      <option key={dept.id} value={dept.id}>{dept.name}</option>
                    ))}
                  </select>
                </div>
              )}

              {formData.recipient === 'staff' && (
                <div>
                  <label className="block text-sm font-medium text-gray-700">Staff Members</label>
                  <select
                    required
                    multiple
                    className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                    value={formData.staff_ids}
                    onChange={(e) => setFormData({
                      ...formData,
                      staff_ids: Array.from(e.target.selectedOptions, option => option.value)
                    })}
                  >
                    {staff.map((member) => (
                      <option key={member.id} value={member.id}>
                        {member.name} - {member.departments?.[0]?.department?.name}
                      </option>
                    ))}
                  </select>
                  <p className="mt-1 text-sm text-gray-500">Hold Ctrl/Cmd to select multiple staff members</p>
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
                  Create Memo
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="space-y-6">
        {memos.map((memo) => (
          <div 
            key={memo.id} 
            className="bg-white rounded-lg shadow-sm hover:shadow-md transition-all duration-200"
          >
            <div className="p-6">
              <div className="flex justify-between items-start mb-4">
                <div className="flex-1">
                  <div className="flex flex-wrap items-center gap-3 mb-2">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${getMemoTypeColor(memo.type)}`}>
                      {getMemoTypeIcon(memo.type)}
                      <span className="ml-2">{getMemoTypeLabel(memo.type)}</span>
                    </span>
                    <span className="text-sm text-gray-500">
                      {new Date(memo.created_at).toLocaleDateString(undefined, {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric'
                      })}
                    </span>
                  </div>
                  <h3 className="text-xl font-semibold text-gray-900">{memo.title}</h3>
                  <div className="mt-2 flex flex-wrap gap-2">
                    {memo.department_name ? (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-sm bg-blue-50 text-blue-700">
                        Department: {memo.department_name}
                      </span>
                    ) : memo.staff_name ? (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-sm bg-green-50 text-green-700">
                        Staff: {memo.staff_name}
                      </span>
                    ) : (
                      <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-sm bg-gray-50 text-gray-700">
                        All Staff
                      </span>
                    )}
                  </div>
                </div>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => handleDownload(memo)}
                    className="text-indigo-600 hover:text-indigo-900 p-2 rounded-full hover:bg-indigo-50 transition-colors"
                    title="Download Memo"
                  >
                    <Download className="h-5 w-5" />
                  </button>
                  <button
                    onClick={() => handleDelete(memo)}
                    className="text-red-600 hover:text-red-900 p-2 rounded-full hover:bg-red-50 transition-colors"
                    title="Delete Memo"
                  >
                    <Trash2 className="h-5 w-5" />
                  </button>
                </div>
              </div>
              <div className="prose prose-sm max-w-none mt-4">
                <p className="text-gray-700 whitespace-pre-wrap">{memo.content}</p>
              </div>
            </div>
          </div>
        ))}
        {memos.length === 0 && (
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Medal className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No memos available</h3>
            <p className="mt-1 text-sm text-gray-500">
              {searchTerm
                ? 'No memos match your search criteria'
                : 'You have no memos at the moment'}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}