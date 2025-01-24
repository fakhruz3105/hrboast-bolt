import React from 'react';
import { Staff } from '../../../../types/staff';

type Props = {
  staff: Staff[];
  selectedStaff: string;
  onChange: (staffId: string) => void;
};

export default function StaffFilter({ staff, selectedStaff, onChange }: Props) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">Select Staff Member</label>
      <select
        required
        className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
        value={selectedStaff}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">Select Staff Member</option>
        {staff.map((member) => (
          <option key={member.id} value={member.id}>
            {member.name} - {member.department?.name}
          </option>
        ))}
      </select>
    </div>
  );
}