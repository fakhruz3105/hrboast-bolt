import React, { useState } from 'react';
import { Staff } from '../../../../types/staff';
import { ShowCauseType, ShowCauseFormData } from '../../../../types/showCause';

type Props = {
  staff: Staff[];
  onSubmit: (data: ShowCauseFormData) => Promise<void>;
  onCancel: () => void;
};

const SHOW_CAUSE_TYPES: { value: ShowCauseType; label: string }[] = [
  { value: 'lateness', label: 'Lateness' },
  { value: 'harassment', label: 'Harassment' },
  { value: 'leave_without_approval', label: 'Leave without Approval' },
  { value: 'offensive_behavior', label: 'Offensive Behavior' },
  { value: 'insubordination', label: 'Insubordination' },
  { value: 'misconduct', label: 'Other Misconduct' }
];

export default function ShowCauseForm({ staff, onSubmit, onCancel }: Props) {
  const [formData, setFormData] = useState<ShowCauseFormData>({
    staff_id: '',
    type: 'lateness',
    title: '',
    incident_date: new Date().toISOString().split('T')[0],
    description: ''
  });
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit(formData);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700">Staff Member</label>
        <select
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.staff_id}
          onChange={(e) => setFormData({ ...formData, staff_id: e.target.value })}
          disabled={loading}
        >
          <option value="">Select Staff Member</option>
          {staff.map((member) => (
            <option key={member.id} value={member.id}>
              {member.name} - {member.departments?.[0]?.department?.name}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Type</label>
        <select
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.type}
          onChange={(e) => setFormData({ ...formData, type: e.target.value as ShowCauseType })}
          disabled={loading}
        >
          {SHOW_CAUSE_TYPES.map((type) => (
            <option key={type.value} value={type.value}>{type.label}</option>
          ))}
        </select>
      </div>

      {formData.type === 'misconduct' && (
        <div>
          <label className="block text-sm font-medium text-gray-700">Title</label>
          <input
            type="text"
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
            disabled={loading}
            placeholder="Enter misconduct title"
          />
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700">Incident Date</label>
        <input
          type="date"
          required
          max={new Date().toISOString().split('T')[0]}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.incident_date}
          onChange={(e) => setFormData({ ...formData, incident_date: e.target.value })}
          disabled={loading}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Description</label>
        <textarea
          required
          rows={4}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          disabled={loading}
          placeholder="Provide detailed description of the incident..."
        />
      </div>

      <div className="flex justify-end space-x-3">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Creating...' : 'Create Show Cause Letter'}
        </button>
      </div>
    </form>
  );
}