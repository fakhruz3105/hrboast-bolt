import React from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import ProfileForm from '../../../components/admin/staff-view/ProfileForm';
import PasswordManagement from '../../../components/admin/staff-view/PasswordManagement';
import ProfileHeader from '../../../components/admin/staff-view/ProfileHeader';
import { toast } from 'react-hot-toast';

export default function MyProfilePage() {
  const { staff, loading, error, updateProfile } = useStaffProfile();

  const handleUpdateProfile = async (updatedData: any) => {
    try {
      await updateProfile(updatedData);
      toast.success('Profile updated successfully!');
    } catch (error) {
      console.error('Error updating profile:', error);
      toast.error('Failed to update profile');
    }
  };

  const handleChangePassword = async (currentPassword: string, newPassword: string) => {
    try {
      const { error } = await supabase.rpc('update_staff_password', {
        p_email: staff?.email,
        p_current_password: currentPassword,
        p_new_password: newPassword
      });

      if (error) throw error;
      toast.success('Password updated successfully!');
    } catch (error) {
      console.error('Error changing password:', error);
      throw new Error('Failed to change password');
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

  if (error) {
    return (
      <div className="p-6">
        <div className="max-w-4xl mx-auto">
          <div className="bg-red-50 border border-red-200 text-red-600 p-4 rounded-lg">
            Error loading profile: {error.message}
          </div>
        </div>
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="p-6">
        <div className="max-w-4xl mx-auto">
          <div className="bg-yellow-50 border border-yellow-200 text-yellow-600 p-4 rounded-lg">
            Profile not found
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">My Profile</h1>
        
        <ProfileHeader staff={staff} />

        <div className="bg-white rounded-lg shadow">
          <div className="p-6">
            <h2 className="text-lg font-medium text-gray-900 mb-6">Personal Information</h2>
            <ProfileForm staff={staff} onSubmit={handleUpdateProfile} />
          </div>

          <div className="border-t border-gray-200">
            <div className="p-6">
              <PasswordManagement onChangePassword={handleChangePassword} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}