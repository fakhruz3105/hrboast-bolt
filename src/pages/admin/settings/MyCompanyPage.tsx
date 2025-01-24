import React, { useState, useEffect } from 'react';
import { Building2, Mail, Phone, MapPin, Calendar, Users } from 'lucide-react';
import { useAuth } from '../../../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import CompanyDetails from '../../../components/admin/settings/company/CompanyDetails';
import { useSupabase } from '../../../providers/SupabaseProvider';

type Company = {
  id: string;
  name: string;
  email: string;
  phone: string;
  address: string;
  ssm?: string;
  logo_url?: string;
  subscription_status: string;
  trial_ends_at: string | null;
  is_active: boolean;
  staff_count: number;
  created_at: string;
};

export default function MyCompanyPage() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [company, setCompany] = useState<Company | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user?.email) {
      loadCompanyDetails();
    }
  }, [user?.email]);

  const loadCompanyDetails = async () => {
    try {
      // First get the staff's company_id
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select('company_id')
        .eq('email', user!.email)
        .single();

      if (staffError) throw staffError;
      if (!staffData?.company_id) throw new Error('No company found');

      // Then get company details
      const { data: companyData, error: companyError } = await supabase
        .from('companies')
        .select('*')
        .eq('id', staffData.company_id)
        .single();

      if (companyError) throw companyError;
      if (!companyData) throw new Error('Company details not found');

      setCompany(companyData);
    } catch (error) {
      console.error('Error loading company details:', error);
      toast.error('Failed to load company details');
    } finally {
      setLoading(false);
    }
  };

  const handleSaveCompanyDetails = async (data: any) => {
    if (!company?.id) return;

    try {
      // Update company details using RPC function
      const { error } = await supabase.rpc('update_company_details', {
        p_company_id: company.id,
        p_name: data.name,
        p_ssm: data.ssm,
        p_address: data.address,
        p_phone: data.phone,
        p_logo_url: data.logo_url
      });

      if (error) throw error;

      toast.success('Company details saved successfully');
      await loadCompanyDetails(); // Reload the data
    } catch (error) {
      console.error('Error saving company details:', error);
      toast.error('Failed to save company details');
      throw error;
    }
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="max-w-4xl mx-auto">
          <div className="animate-pulse">
            <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
            <div className="h-32 bg-gray-200 rounded mb-6"></div>
            <div className="h-64 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!company) {
    return (
      <div className="p-6">
        <div className="max-w-4xl mx-auto">
          <div className="text-center py-12 bg-white rounded-lg shadow">
            <Building2 className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No Company Found</h3>
            <p className="mt-1 text-sm text-gray-500">Unable to load company details.</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">Company Profile</h1>
          <p className="mt-1 text-sm text-gray-500">View and manage your company details</p>
        </div>

        {/* Company Details Form */}
        <CompanyDetails
          initialData={{
            name: company.name,
            ssm: company.ssm || '',
            address: company.address,
            phone: company.phone,
            logo_url: company.logo_url
          }}
          onSave={handleSaveCompanyDetails}
        />

        {/* Company Statistics */}
        <div className="mt-8 grid grid-cols-1 gap-5 sm:grid-cols-3">
          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <Users className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      Total Staff
                    </dt>
                    <dd className="text-lg font-semibold text-gray-900">
                      {company.staff_count}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <Calendar className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      Member Since
                    </dt>
                    <dd className="text-lg font-semibold text-gray-900">
                      {new Date(company.created_at).toLocaleDateString()}
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>

          <div className="bg-white overflow-hidden shadow rounded-lg">
            <div className="p-5">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <Building2 className="h-6 w-6 text-gray-400" />
                </div>
                <div className="ml-5 w-0 flex-1">
                  <dl>
                    <dt className="text-sm font-medium text-gray-500 truncate">
                      Status
                    </dt>
                    <dd className="text-lg font-semibold text-gray-900">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        company.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                      }`}>
                        {company.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </dd>
                  </dl>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}