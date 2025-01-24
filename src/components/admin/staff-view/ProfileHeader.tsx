import React from 'react';
import { Staff } from '../../../types/staff';

type Props = {
  staff: Staff;
};

export default function ProfileHeader({ staff }: Props) {
  const getPrimaryDepartment = () => {
    const primaryDept = staff.departments?.find(d => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const getPrimaryLevel = () => {
    const primaryLevel = staff.levels?.find(l => l.is_primary);
    return primaryLevel?.level?.name || 'N/A';
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-sm mb-6">
      <div className="flex items-center space-x-4">
        <div className="flex-1">
          <h2 className="text-xl font-semibold text-gray-900">{staff.name}</h2>
          <p className="text-gray-500">{getPrimaryDepartment()} - {getPrimaryLevel()}</p>
        </div>
        <div className="text-right">
          <div className="text-sm text-gray-500">Employee since</div>
          <div className="font-medium">{new Date(staff.join_date).toLocaleDateString()}</div>
        </div>
      </div>
    </div>
  );
}