import React, { useState, useEffect } from 'react';
import { supabase } from '../../../lib/supabase';
import { Plus, Lock, Unlock, Edit, Trash2, KeyRound } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useAuth } from '../../../contexts/AuthContext';
import CompanyCleanup from '../../../components/admin/settings/companies/CompanyCleanup';

type Company = {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  address: string | null;
  subscription_status: string;
  trial_ends_at: string | null;
  is_active: boolean;
  staff_count: number;
  created_at: string;
};

type PasswordFormData = {
  password: string;
  confirmPassword: string;
};

export default function CompaniesPage() {
  const { user } = useAuth();
  const [companies, setCompanies] = useState<Company[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingCompany, setEditingCompany] = useState<Company | null>(null);
  const [showPasswordForm, setShowPasswordForm] = useState(false);
  const [selectedCompany, setSelectedCompany] = useState<Company | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    address: ''
  });
  const [passwordFormData, setPasswordFormData] = useState<PasswordFormData>({
    password: '',
    confirmPassword: ''
  });

  useEffect(() => {
    loadCompanies();
  }, []);

  const loadCompanies = async () => {
    try {
      const { data, error } = await supabase.rpc('get_all_companies');

      if (error) throw error;
      setCompanies(data || []);
    } catch (error) {
      console.error('Error loading companies:', error);
      toast.error('Failed to load companies');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (formData.password !== formData.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    try {
      if (editingCompany) {
        const { error } = await supabase
          .from('companies')
          .update(formData)
          .eq('id', editingCompany.id);

        if (error) throw error;
        toast.success('Company updated successfully');
      } else {
        const { error } = await supabase.rpc('create_company', {
          p_name: formData.name,
          p_email: formData.email,
          p_phone: formData.phone,
          p_address: formData.address
        });

        if (error) throw error;
        toast.success('Company created successfully');
      }

      setShowForm(false);
      setEditingCompany(null);
      loadCompanies();
    } catch (error) {
      console.error('Error saving company:', error);
      toast.error('Failed to save company');
    }
  };

  const handleEdit = (company: Company) => {
    setEditingCompany(company);
    setFormData({
      name: company.name,
      email: company.email,
      phone: company.phone || '',
      address: company.address || ''
    });
    setShowForm(true);
  };

  const handleDelete = async (company: Company) => {
    if (!window.confirm('Are you sure you want to delete this company?')) return;

    try {
      const { error } = await supabase
        .from('companies')
        .delete()
        .eq('id', company.id);

      if (error) throw error;
      toast.success('Company deleted successfully');
      loadCompanies();
    } catch (error) {
      console.error('Error deleting company:', error);
      toast.error('Failed to delete company');
    }
  };

  const handleToggleActive = async (company: Company) => {
    try {
      if (company.is_active) {
        const { error } = await supabase
          .from('companies')
          .update({ is_active: false })
          .eq('id', company.id);

        if (error) throw error;
        toast.success('Company deactivated successfully');
      } else {
        const { error } = await supabase.rpc('activate_company', {
          p_company_id: company.id
        });

        if (error) throw error;
        toast.success('Company activated successfully');
      }
      loadCompanies();
    } catch (error) {
      console.error('Error toggling company status:', error);
      toast.error('Failed to update company status');
    }
  };

  const handlePasswordSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCompany) return;

    if (passwordFormData.password !== passwordFormData.confirmPassword) {
      toast.error('Passwords do not match');
      return;
    }

    try {
      const { error } = await supabase.rpc('update_company_admin_password', {
        p_company_id: selectedCompany.id,
        p_password: passwordFormData.password
      });

      if (error) {
        console.error('Error updating password:', error);
        toast.error('Failed to update password');
        return;
      }

      toast.success('Admin password updated successfully');
      setShowPasswordForm(false);
      setSelectedCompany(null);
      setPasswordFormData({ password: '', confirmPassword: '' });
    } catch (error) {
      console.error('Error updating password:', error);
      toast.error('An unexpected error occurred');
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
          <h1 className="text-2xl font-bold text-gray-900">Companies</h1>
          <p className="mt-1 text-sm text-gray-500">Manage registered companies</p>
        </div>
        <button
          onClick={() => {
            setEditingCompany(null);
            setFormData({ name: '', email: '', phone: '', address: '' });
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Company
        </button>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Company</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trial</th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {companies.map((company) => (
              <tr key={company.id} className="hover:bg-gray-50">
                <td className="px-6 py-4">
                  <div className="text-sm font-medium text-gray-900">{company.name}</div>
                  <div className="text-sm text-gray-500">{company.staff_count} staff</div>
                </td>
                <td className="px-6 py-4">
                  <div className="text-sm text-gray-900">{company.email}</div>
                  <div className="text-sm text-gray-500">{company.phone}</div>
                </td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    company.is_active 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-red-100 text-red-800'
                  }`}>
                    {company.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-6 py-4">
                  {company.trial_ends_at ? (
                    <div className="text-sm text-gray-500">
                      Ends {new Date(company.trial_ends_at).toLocaleDateString()}
                    </div>
                  ) : (
                    <div className="text-sm text-gray-500">-</div>
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                  <button
                    onClick={() => handleToggleActive(company)}
                    className={`text-${company.is_active ? 'red' : 'green'}-600 hover:text-${company.is_active ? 'red' : 'green'}-900`}
                    title={company.is_active ? 'Deactivate Company' : 'Activate Company'}
                  >
                    {company.is_active ? <Lock className="h-4 w-4" /> : <Unlock className="h-4 w-4" />}
                  </button>
                  <button
                    onClick={() => {
                      setSelectedCompany(company);
                      setShowPasswordForm(true);
                    }}
                    className="text-blue-600 hover:text-blue-900"
                    title="Manage Admin Password"
                  >
                    <KeyRound className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleEdit(company)}
                    className="text-indigo-600 hover:text-indigo-900"
                    title="Edit Company"
                  >
                    <Edit className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(company)}
                    className="text-red-600 hover:text-red-900"
                    title="Delete Company"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                  <CompanyCleanup 
                    companyId={company.id}
                    onCleanupComplete={loadCompanies}
                  />
                </td>
              </tr>
            ))}
            {companies.length === 0 && (
              <tr>
                <td colSpan={5} className="px-6 py-4 text-center text-gray-500">
                  No companies found
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Add/Edit Company Modal */}
      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h2 className="text-lg font-semibold mb-4">
              {editingCompany ? 'Edit Company' : 'Add Company'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Company Name</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Admin Email</label>
                <input
                  type="email"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                />
                <p className="mt-1 text-sm text-gray-500">This email will be used for admin login</p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Phone</label>
                <input
                  type="tel"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.phone}
                  onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Address</label>
                <textarea
                  rows={3}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.address}
                  onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                />
              </div>

              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowForm(false);
                    setEditingCompany(null);
                  }}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                >
                  {editingCompany ? 'Update Company' : 'Add Company'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Admin Password Management Modal */}
      {showPasswordForm && selectedCompany && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <h2 className="text-lg font-semibold mb-4">
              Update Admin Password - {selectedCompany.name}
            </h2>
            <form onSubmit={handlePasswordSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Admin Email</label>
                <input
                  type="email"
                  readOnly
                  className="mt-1 block w-full rounded-md border border-gray-300 bg-gray-50 px-3 py-2"
                  value={selectedCompany.email}
                />
                <p className="mt-1 text-sm text-gray-500">This email is used for admin login</p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">New Admin Password</label>
                <input
                  type="password"
                  required
                  minLength={8}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={passwordFormData.password}
                  onChange={(e) => setPasswordFormData({ ...passwordFormData, password: e.target.value })}
                  placeholder="Enter new admin password"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Confirm Password</label>
                <input
                  type="password"
                  required
                  minLength={8}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={passwordFormData.confirmPassword}
                  onChange={(e) => setPasswordFormData({ ...passwordFormData, confirmPassword: e.target.value })}
                  placeholder="Confirm new admin password"
                />
              </div>

              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => {
                    setShowPasswordForm(false);
                    setSelectedCompany(null);
                    setPasswordFormData({ password: '', confirmPassword: '' });
                  }}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                >
                  Update Admin Password
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}