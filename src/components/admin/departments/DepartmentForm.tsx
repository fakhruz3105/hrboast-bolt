import React, { useState } from 'react';
import { DepartmentFormData } from '../../../types/department';
import { StaffLevel } from '../../../types/staffLevel';

type Props = {
  initialData?: DepartmentFormData | null;
  defaultLevel?: StaffLevel | null;
  staffLevels: StaffLevel[];
  onSubmit: (data: DepartmentFormData & { defaultLevelId?: string }) => void;
  onCancel: () => void;
};

export default function DepartmentForm({ 
  initialData, 
  defaultLevel,
  staffLevels,
  onSubmit, 
  onCancel 
}: Props) {
  const [formData, setFormData] = useState<DepartmentFormData & { defaultLevelId?: string }>({
    name: initialData?.name || '',
    description: initialData?.description || '',
    defaultLevelId: defaultLevel?.id || ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700">Department Name</label>
        <input
          type="text"
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700">Description</label>
        <textarea
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.description || ''}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Default Staff Level</label>
        <select
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.defaultLevelId}
          onChange={(e) => setFormData({ ...formData, defaultLevelId: e.target.value })}
        >
          <option value="">No Default Level</option>
          {staffLevels.map((level) => (
            <option key={level.id} value={level.id}>{level.name}</option>
          ))}
        </select>
        <p className="mt-1 text-sm text-gray-500">
          This level will be automatically assigned to new staff members in this department
        </p>
      </div>

      <div className="flex justify-end space-x-3">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          {initialData ? 'Update Department' : 'Create Department'}
        </button>
      </div>
    </form>
  );
}