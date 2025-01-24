import React from 'react';
import { Staff } from '../../../types/staff';

type Props = {
  staff: Staff[];
  onSelect: (staffId: string) => void;
  onCancel: () => void;
  loading?: boolean;
};

export default function StaffSelector({ staff, onSelect, onCancel, loading }: Props) {
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 gap-4 max-h-96 overflow-y-auto">
        {staff.map((member) => (
          <button
            key={member.id}
            onClick={() => onSelect(member.id)}
            disabled={loading}
            className="p-4 text-left rounded-lg border border-gray-200 hover:border-indigo-500 hover:bg-indigo-50 transition-colors"
          >
            <div className="font-medium text-gray-900">{member.name}</div>
            <div className="text-sm text-gray-500">{member.department?.name}</div>
          </button>
        ))}
      </div>

      <div className="flex justify-end space-x-3 pt-4 border-t">
        <button
          type="button"
          onClick={onCancel}
          disabled={loading}
          className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}