import React, { useState, useEffect } from 'react';
import { Plus, Search, Filter, Gift, Clock, CheckCircle, AlertCircle } from 'lucide-react';
import { supabase } from '../../../lib/supabase';
import { useAuth } from '../../../contexts/AuthContext';
import BenefitList from '../../../components/admin/benefits/BenefitList';
import BenefitForm from '../../../components/admin/benefits/BenefitForm';
import BenefitEligibilityForm from '../../../components/admin/benefits/BenefitEligibilityForm';
import { toast } from 'react-hot-toast';

type Benefit = {
  id: string;
  name: string;
  description: string | null;
  amount: number;
  status: boolean;
  frequency: string;
  company_id: string;
};

export default function ManageBenefitsPage() {
  const { user } = useAuth();
  const [benefits, setBenefits] = useState<Benefit[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [editingBenefit, setEditingBenefit] = useState<Benefit | null>(null);
  const [managingEligibility, setManagingEligibility] = useState<Benefit | null>(null);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [frequencyFilter, setFrequencyFilter] = useState<string>('all');

  useEffect(() => {
    if (user?.email) {
      loadBenefits();
    }
  }, [user?.email]);

  const loadBenefits = async () => {
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

      // Then load benefits for this company
      const { data: benefitsData, error: benefitsError } = await supabase
        .from('benefits')
        .select('*')
        .eq('company_id', staffData.company_id)
        .order('created_at', { ascending: false });

      if (benefitsError) throw benefitsError;
      setBenefits(benefitsData || []);
    } catch (error) {
      console.error('Error loading benefits:', error);
      toast.error('Failed to load benefits');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (formData: any) => {
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

      if (editingBenefit) {
        // Update existing benefit
        const { data, error } = await supabase
          .from('benefits')
          .update({
            name: formData.name,
            description: formData.description,
            amount: formData.amount,
            frequency: formData.frequency
          })
          .eq('id', editingBenefit.id)
          .eq('company_id', staffData.company_id)
          .select()
          .single();

        if (error) throw error;
        setBenefits(prev => prev.map(b => b.id === data.id ? data : b));
        toast.success('Benefit updated successfully');
      } else {
        // Create new benefit
        const { data, error } = await supabase
          .from('benefits')
          .insert([{
            name: formData.name,
            description: formData.description,
            amount: formData.amount,
            frequency: formData.frequency,
            company_id: staffData.company_id,
            status: true
          }])
          .select()
          .single();

        if (error) throw error;
        setBenefits(prev => [data, ...prev]);
        toast.success('Benefit created successfully');
      }
      
      setShowForm(false);
      setEditingBenefit(null);
    } catch (error: any) {
      console.error('Error saving benefit:', error);
      toast.error('Failed to save benefit');
    }
  };

  const handleEdit = (benefit: Benefit) => {
    setEditingBenefit(benefit);
    setShowForm(true);
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this benefit?')) return;

    try {
      // Get company ID for current user
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (staffError) throw staffError;

      const { error } = await supabase
        .from('benefits')
        .delete()
        .eq('id', id)
        .eq('company_id', staffData?.company_id);

      if (error) throw error;
      
      setBenefits(prev => prev.filter(benefit => benefit.id !== id));
      toast.success('Benefit deleted successfully');
    } catch (error) {
      console.error('Error deleting benefit:', error);
      toast.error('Failed to delete benefit');
    }
  };

  const handleManageEligibility = (benefit: Benefit) => {
    setManagingEligibility(benefit);
  };

  // Filter benefits
  const filteredBenefits = benefits.filter(benefit => {
    const matchesSearch = benefit.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         benefit.description?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' ? true :
                         statusFilter === 'active' ? benefit.status :
                         !benefit.status;
    const matchesFrequency = frequencyFilter === 'all' ? true :
                            benefit.frequency === frequencyFilter;
    
    return matchesSearch && matchesStatus && matchesFrequency;
  });

  // Calculate statistics
  const stats = {
    total: benefits.length,
    active: benefits.filter(b => b.status).length,
    inactive: benefits.filter(b => !b.status).length,
    totalValue: benefits.reduce((sum, b) => sum + (b.status ? b.amount : 0), 0)
  };

  // Get unique frequencies for filter
  const frequencies = Array.from(new Set(benefits.map(b => b.frequency)));

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-4 gap-4 mb-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-24 bg-gray-200 rounded"></div>
            ))}
          </div>
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
          <h1 className="text-2xl font-bold text-gray-900">Manage Benefits</h1>
          <p className="mt-1 text-sm text-gray-500">Create and manage employee benefits</p>
        </div>
        <button
          onClick={() => {
            setEditingBenefit(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Benefit
        </button>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-indigo-100 text-indigo-600">
              <Gift className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total Benefits</p>
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
              <p className="text-sm font-medium text-gray-500">Active Benefits</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.active}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-red-100 text-red-600">
              <AlertCircle className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Inactive Benefits</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.inactive}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-sm">
          <div className="flex items-center">
            <div className="p-3 rounded-lg bg-amber-100 text-amber-600">
              <Clock className="h-6 w-6" />
            </div>
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total Value</p>
              <p className="text-2xl font-semibold text-gray-900">RM {stats.totalValue.toFixed(2)}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm mb-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {/* Search */}
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search benefits..."
              className="pl-10 block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Status Filter */}
          <div>
            <select
              className="block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as 'all' | 'active' | 'inactive')}
            >
              <option value="all">All Status</option>
              <option value="active">Active Only</option>
              <option value="inactive">Inactive Only</option>
            </select>
          </div>

          {/* Frequency Filter */}
          <div>
            <select
              className="block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={frequencyFilter}
              onChange={(e) => setFrequencyFilter(e.target.value)}
            >
              <option value="all">All Frequencies</option>
              {frequencies.map(freq => (
                <option key={freq} value={freq}>{freq}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Benefits List */}
      <div className="bg-white rounded-lg shadow-sm">
        <BenefitList
          benefits={filteredBenefits}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onManageEligibility={handleManageEligibility}
        />
      </div>

      {showForm && (
        <BenefitForm
          initialData={editingBenefit}
          onSubmit={handleSubmit}
          onCancel={() => {
            setShowForm(false);
            setEditingBenefit(null);
          }}
        />
      )}

      {managingEligibility && (
        <BenefitEligibilityForm
          benefitId={managingEligibility.id}
          onClose={() => setManagingEligibility(null)}
        />
      )}
    </div>
  );
}