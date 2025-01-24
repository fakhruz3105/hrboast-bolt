import React, { useState } from 'react';
import { StaffLevel } from '../../../../types/staffLevel';
import { Role } from '../../../../types/role';
import { toast } from 'react-hot-toast';

type Props = {
  staffLevels: StaffLevel[];
  onSubmit: (data: { staff_level_id: string; role: Role }) => Promise<void>;
};

export default function RoleMappingForm({ staffLevels, onSubmit }: Props) {
  const [formData, setFormData] = useState({
    staff_level_id: '',
    role: 'staff' as Role
  });
  const [loading, setLoading] = useState(false);

  const roles: { value: Role; label: string }[] = [
    { value: 'admin', label: 'Admin' },
    { value: 'hr', label: 'HR' },
    { value: 'staff', label: 'Staff' }
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.staff_level_id) {
      toast.error('Please select a staff level');
      return;
    }

    setLoading(true);
    try {
      await onSubmit(formData);
      toast.success('Role mapping updated successfully');
      setFormData({ staff_level_id: '', role: 'staff' });
    } catch (error) {
      console.error('Error saving role mapping:', error);
      toast.error('Failed to update role mapping');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Staff Level</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.staff_level_id}
            onChange={(e) => setFormData({ ...formData, staff_level_id: e.target.value })}
            disabled={loading}
          >
            <option value="">Select Staff Level</option>
            {staffLevels.map((level) => (
              <option key={level.id} value={level.id}>{level.name}</option>
            ))}
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Role</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.role}
            onChange={(e) => setFormData({ ...formData, role: e.target.value as Role })}
            disabled={loading}
          >
            {roles.map((role) => (
              <option key={role.value} value={role.value}>{role.label}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="flex justify-end">
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Assigning...' : 'Assign Role'}
        </button>
      </div>
    </form>
  );
}