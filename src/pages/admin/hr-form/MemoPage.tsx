import React, { useState, useEffect } from 'react';
import { Plus, Search, Filter, Medal, Gift, TrendingUp, DollarSign, Edit, Trash2 } from 'lucide-react';
import { useDepartments } from '../../../hooks/useDepartments';
import { useStaff } from '../../../hooks/useStaff';
import { MemoType } from '../../../types/memo';
import { useAuth } from '../../../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function MemoPage() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const { departments } = useDepartments();
  const { staff } = useStaff();
  const [memos, setMemos] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [editingMemo, setEditingMemo] = useState<any>(null);
  const [staffSearchTerm, setStaffSearchTerm] = useState('');
  const [formData, setFormData] = useState({
    title: '',
    type: 'recognition' as MemoType,
    content: '',
    recipient: 'all',
    department_id: '',
    staff_ids: [] as string[]
  });

  const filteredStaff = staff.filter(member => {
    const searchLower = staffSearchTerm.toLowerCase();
    return (
      member.name.toLowerCase().includes(searchLower) ||
      member.departments?.some(d => d.department.name.toLowerCase().includes(searchLower)) ||
      member.email.toLowerCase().includes(searchLower)
    );
  });

  useEffect(() => {
    if (user?.email) {
      loadMemos();
    }
  }, [user?.email]);

  useEffect(() => {
    if (editingMemo) {
      setFormData({
        title: editingMemo.title,
        type: editingMemo.type,
        content: editingMemo.content,
        recipient: editingMemo.staff_id ? 'staff' : editingMemo.department_id ? 'department' : 'all',
        department_id: editingMemo.department_id || '',
        staff_ids: editingMemo.staff_id ? [editingMemo.staff_id] : []
      });
      setShowForm(true);
    }
  }, [editingMemo]);

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
      if (!staffData?.company_id) {
        toast.error('Company not found');
        return;
      }

      const { data: memosData, error: memosError } = await supabase
        .from('memos')
        .select(`
          *,
          department:department_id(name),
          staff:staff_id(name)
        `)
        .eq('company_id', staffData.company_id)
        .order('created_at', { ascending: false });

      if (memosError) throw memosError;
      setMemos(memosData || []);
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
        company_id: staffData.company_id,
        department_id: formData.recipient === 'department' ? formData.department_id : null,
        staff_id: formData.recipient === 'staff' ? formData.staff_ids[0] : null
      };

      if (editingMemo) {
        // Update existing memo
        const { error: updateError } = await supabase
          .from('memos')
          .update(memoData)
          .eq('id', editingMemo.id);

        if (updateError) throw updateError;
        toast.success('Memo updated successfully');
      } else {
        // Create new memo(s)
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
          const { error: insertError } = await supabase
            .from('memos')
            .insert([memoData]);

          if (insertError) throw insertError;
        }
        toast.success('Memo created successfully');
      }

      setShowForm(false);
      setEditingMemo(null);
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
      console.error('Error saving memo:', error);
      toast.error('Failed to save memo');
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
        return 'bg-purple-100 text-purple-800 ring-purple-200';
      case 'rewards':
        return 'bg-green-100 text-green-800 ring-green-200';
      case 'bonus':
        return 'bg-blue-100 text-blue-800 ring-blue-200';
      case 'salary_increment':
        return 'bg-amber-100 text-amber-800 ring-amber-200';
      default:
        return 'bg-gray-100 text-gray-800 ring-gray-200';
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

  const filteredMemos = memos.filter(memo => {
    const matchesSearch = searchTerm === '' || 
      memo.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      memo.content.toLowerCase().includes(searchTerm.toLowerCase());
    
    return matchesSearch;
  });

  const memoTypes = [
    { type: 'recognition', label: 'Recognition', icon: Medal },
    { type: 'rewards', label: 'Rewards', icon: Gift },
    { type: 'bonus', label: 'Bonus', icon: TrendingUp },
    { type: 'salary_increment', label: 'Increment', icon: DollarSign }
  ];

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="bg-gray-200 h-40 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">Achievement Memos</h1>
            <p className="mt-1 text-sm text-gray-500">Create and manage achievement memos</p>
          </div>

          {/* Search Bar */}
          <div className="relative w-full md:w-64">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search achievements..."
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        {/* Type Filters */}
        <div className="flex flex-wrap gap-2 mb-6">
          <button
            onClick={() => setFormData(prev => ({ ...prev, type: 'recognition' }))}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
              formData.type === 'recognition'
                ? 'bg-indigo-100 text-indigo-800 ring-2 ring-indigo-200'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All
          </button>
          {memoTypes.map(({ type, label, icon: Icon }) => (
            <button
              key={type}
              onClick={() => setFormData(prev => ({ ...prev, type: type as MemoType }))}
              className={`inline-flex items-center px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                formData.type === type
                  ? getMemoTypeColor(type)
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <Icon className="h-4 w-4 mr-2" />
              {label}
            </button>
          ))}
        </div>

        {/* Create Memo Button */}
        <button
          onClick={() => {
            setEditingMemo(null);
            setFormData({
              title: '',
              type: 'recognition',
              content: '',
              recipient: 'all',
              department_id: '',
              staff_ids: []
            });
            setShowForm(true);
          }}
          className="mb-6 inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create Achievement Memo
        </button>

        {/* Create/Edit Memo Form */}
        {showForm && (
          <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center overflow-y-auto p-4">
            <div className="bg-white rounded-lg shadow-lg w-full max-w-2xl my-8">
              {/* Form Header */}
              <div className="flex justify-between items-center p-6 border-b border-gray-200">
                <h2 className="text-xl font-bold">
                  {editingMemo ? 'Edit Achievement Memo' : 'Create Achievement Memo'}
                </h2>
                <button 
                  onClick={() => {
                    setShowForm(false);
                    setEditingMemo(null);
                  }}
                  className="text-gray-500 hover:text-gray-700"
                >
                  ×
                </button>
              </div>

              {/* Form Content - Make scrollable while keeping buttons fixed */}
              <form onSubmit={handleSubmit} className="flex flex-col h-full max-h-[calc(100vh-16rem)]">
                <div className="flex-1 overflow-y-auto p-6 space-y-6">
                  {/* Title Field */}
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

                  {/* Type Field */}
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

                  {/* Content Field */}
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

                  {/* Recipient Field */}
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
                      <div className="space-y-2">
                        {/* Staff search input */}
                        <div className="relative">
                          <Search className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                          <input
                            type="text"
                            placeholder="Search staff by name, email, or department..."
                            className="pl-10 block w-full rounded-md border border-gray-300 px-3 py-2 mb-2"
                            value={staffSearchTerm}
                            onChange={(e) => setStaffSearchTerm(e.target.value)}
                          />
                        </div>
                        
                        {/* Staff selection list */}
                        <select
                          required
                          multiple
                          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 h-48"
                          value={formData.staff_ids}
                          onChange={(e) => setFormData({
                            ...formData,
                            staff_ids: Array.from(e.target.selectedOptions, option => option.value)
                          })}
                        >
                          {filteredStaff.map((member) => {
                            const primaryDept = member.departments?.find(d => d.is_primary)?.department.name;
                            return (
                              <option key={member.id} value={member.id}>
                                {member.name} - {primaryDept || 'No Department'} ({member.email})
                              </option>
                            );
                          })}
                        </select>
                        <p className="mt-1 text-sm text-gray-500">
                          {filteredStaff.length === 0 ? (
                            'No staff members found matching your search'
                          ) : (
                            'Hold Ctrl/Cmd to select multiple staff members'
                          )}
                        </p>
                        {formData.staff_ids.length > 0 && (
                          <p className="text-sm text-indigo-600">
                            {formData.staff_ids.length} staff member{formData.staff_ids.length > 1 ? 's' : ''} selected
                          </p>
                        )}
                      </div>
                    </div>
                  )}
                </div>

                {/* Form Actions - Fixed at bottom */}
                <div className="border-t border-gray-200 p-6 bg-white">
                  <div className="flex justify-end space-x-3">
                    <button
                      type="button"
                      onClick={() => {
                        setShowForm(false);
                        setEditingMemo(null);
                      }}
                      className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                    >
                      Cancel
                    </button>
                    <button
                      type="submit"
                      className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                    >
                      {editingMemo ? 'Update Memo' : 'Create Memo'}
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Memos List */}
        <div className="space-y-6">
          {filteredMemos.length > 0 ? (
            filteredMemos.map((memo) => (
              <div 
                key={memo.id} 
                className="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-200 overflow-hidden"
              >
                <div className="p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
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
                      {(memo.department_name || memo.staff_name) && (
                        <p className="text-sm text-gray-600 mt-1">
                          {memo.department_name && `Department: ${memo.department_name}`}
                          {memo.staff_name && `Staff: ${memo.staff_name}`}
                          {!memo.department_name && !memo.staff_name && 'All Staff'}
                        </p>
                      )}
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => setEditingMemo(memo)}
                        className="text-blue-600 hover:text-blue-900 p-2 rounded-full hover:bg-blue-50 transition-colors"
                        title="Edit Memo"
                      >
                        <Edit className="h-5 w-5" />
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
            ))
          ) : (
            <div className="text-center py-12 bg-white rounded-xl shadow-sm">
              <Medal className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No achievements yet</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchTerm
                  ? 'No achievements match your search criteria'
                  : 'Your achievements will appear here'}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}