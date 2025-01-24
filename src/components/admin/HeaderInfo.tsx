import React, { useEffect, useState } from 'react';
import { Building2, User } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../providers/SupabaseProvider';

export default function HeaderInfo() {
  const supabase = useSupabase();
  const { user } = useAuth();
  const [companyName, setCompanyName] = useState<string>('');
  const [staffName, setStaffName] = useState<string>('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (user?.email) {
      loadUserDetails();
    }
  }, [user?.email]);

  const loadUserDetails = async () => {
    try {
      setLoading(true);

      // For demo users, set predefined names
      if (user?.email === 'admin@example.com') {
        setCompanyName('Muslimtravelbug Sdn Bhd');
        setStaffName('Mohd Saddam Irrban');
        return;
      }

      if (user?.email === 'staff@example.com') {
        setCompanyName('Muslimtravelbug Sdn Bhd');
        setStaffName('Demo Staff');
        return;
      }

      // For real users, load from database
      if (user?.company_id) {
        // Get company details
        const { data: companyData, error: companyError } = await supabase
          .from('companies')
          .select('name')
          .eq('id', user.company_id)
          .single();

        if (companyError) throw companyError;
        if (companyData) {
          setCompanyName(companyData.name);
        }

        // Get staff details if not admin
        if (user.role !== 'admin') {
          const { data: staffData, error: staffError } = await supabase
            .from('staff')
            .select(`
              name,
              departments:staff_departments(
                is_primary,
                department:departments(name)
              ),
              levels:staff_levels_junction(
                is_primary,
                level:staff_levels(name)
              )
            `)
            .eq('id', user.id)
            .single();

          if (staffError) throw staffError;
          if (staffData) {
            setStaffName(staffData.name);
          }
        } else {
          // For admin users, use company name + "Admin"
          setStaffName(`${companyData?.name} Admin`);
        }
      }
    } catch (error) {
      console.error('Error loading user details:', error);
      toast.error('Failed to load user details');
    } finally {
      setLoading(false);
    }
  };

  if (loading || (!companyName && !staffName)) return null;

  return (
    <div className="bg-white border-b border-gray-200 fixed top-0 right-0 left-0 z-[40] lg:left-64">
      <div className="h-16 px-4 flex items-center">
        {/* Mobile Menu Space - Left */}
        <div className="w-10 lg:hidden"></div>

        {/* Content - Center/Right */}
        <div className="flex-1 flex items-center justify-end">
          <div className="flex items-center space-x-4">
            {/* Company Name - Hidden on mobile */}
            {companyName && (
              <div className="hidden md:flex items-center text-gray-600">
                <Building2 className="h-4 w-4 mr-1 flex-shrink-0" />
                <span className="text-sm font-medium truncate">{companyName}</span>
              </div>
            )}

            {/* Separator - Hidden on mobile */}
            <span className="hidden md:block text-gray-300">|</span>

            {/* Staff Name - Always visible */}
            {staffName && (
              <div className="flex items-center text-gray-600">
                <User className="h-4 w-4 mr-1 flex-shrink-0" />
                <span className="text-sm font-medium truncate max-w-[120px] md:max-w-none">
                  {staffName}
                </span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}