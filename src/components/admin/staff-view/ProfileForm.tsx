import React, { useState } from 'react';
import { Staff } from '../../../types/staff';
import { toast } from 'react-hot-toast';

type Props = {
  staff: Staff;
  onSubmit: (data: Partial<Staff>) => Promise<void>;
};

export default function ProfileForm({ staff, onSubmit }: Props) {
  const [formData, setFormData] = useState({
    name: staff.name,
    phone_number: staff.phone_number,
    email: staff.email
  });

  const getPrimaryDepartment = () => {
    const primaryDept = staff.departments?.find(d => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const getPrimaryLevel = () => {
    const primaryLevel = staff.levels?.find(l => l.is_primary);
    return primaryLevel?.level?.name || 'N/A';
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await onSubmit(formData);
      toast.success('Profile updated successfully');
    } catch (error) {
      console.error('Error updating profile:', error);
      toast.error('Failed to update profile');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="grid grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700">Department</label>
          <input
            type="text"
            className="mt-1 block w-full rounded-md border border-gray-300 bg-gray-100 px-3 py-2"
            value={getPrimaryDepartment()}
            disabled
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Level</label>
          <input
            type="text"
            className="mt-1 block w-full rounded-md border border-gray-300 bg-gray-100 px-3 py-2"
            value={getPrimaryLevel()}
            disabled
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Full Name</label>
        <input
          type="text"
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Phone Number</label>
        <input
          type="tel"
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.phone_number}
          onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
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

      <div className="flex justify-end">
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          Update Profile
        </button>
      </div>
    </form>
  );
}