import React, { useState } from 'react';
import { WarningLetterFormData, WarningLevel } from '../../../../types/warningLetter';
import { Staff } from '../../../../types/staff';

type Props = {
  staff: Staff[];
  initialData?: WarningLetterFormData | null;
  onSubmit: (data: WarningLetterFormData) => Promise<void>;
  onCancel: () => void;
};

export default function WarningLetterForm({ staff, initialData, onSubmit, onCancel }: Props) {
  const today = new Date().toISOString().split('T')[0];
  const [formData, setFormData] = useState<WarningLetterFormData>({
    staff_id: initialData?.staff_id || '',
    warning_level: initialData?.warning_level || 'first',
    incident_date: initialData?.incident_date || today,
    description: initialData?.description || '',
    improvement_plan: initialData?.improvement_plan || '',
    consequences: initialData?.consequences || '',
    issued_date: initialData?.issued_date || today
  });
  const [loading, setLoading] = useState(false);

  const warningLevels: { value: WarningLevel; label: string }[] = [
    { value: 'first', label: 'First Warning' },
    { value: 'second', label: 'Second Warning' },
    { value: 'final', label: 'Final Warning' }
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validate dates
    const incidentDate = new Date(formData.incident_date);
    const issuedDate = new Date(formData.issued_date);
    const now = new Date();

    if (incidentDate > now) {
      alert('Incident date cannot be in the future');
      return;
    }

    if (issuedDate > now) {
      alert('Issue date cannot be in the future');
      return;
    }

    if (issuedDate < incidentDate) {
      alert('Issue date must be after or equal to incident date');
      return;
    }

    setLoading(true);
    try {
      await onSubmit(formData);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setLoading(false);
    }
  };

  // Filter active staff members
  const activeStaff = staff.filter(member => member.status !== 'resigned');

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
          {activeStaff.map((member) => {
            const primaryDept = member.departments?.find(d => d.is_primary);
            return (
              <option key={member.id} value={member.id}>
                {member.name} - {primaryDept?.department?.name || 'No Department'}
              </option>
            );
          })}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Warning Level</label>
        <select
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.warning_level}
          onChange={(e) => setFormData({ ...formData, warning_level: e.target.value as WarningLevel })}
          disabled={loading}
        >
          {warningLevels.map((level) => (
            <option key={level.value} value={level.value}>
              {level.label}
            </option>
          ))}
        </select>
      </div>

      <div className="grid grid-cols-2 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700">Incident Date</label>
          <input
            type="date"
            required
            max={today}
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.incident_date}
            onChange={(e) => setFormData({ ...formData, incident_date: e.target.value })}
            disabled={loading}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Issue Date</label>
          <input
            type="date"
            required
            max={today}
            min={formData.incident_date}
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.issued_date}
            onChange={(e) => setFormData({ ...formData, issued_date: e.target.value })}
            disabled={loading}
          />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Description of Incident</label>
        <textarea
          required
          rows={4}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
          placeholder="Describe the incident or violation in detail..."
          disabled={loading}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Improvement Plan</label>
        <textarea
          required
          rows={4}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.improvement_plan}
          onChange={(e) => setFormData({ ...formData, improvement_plan: e.target.value })}
          placeholder="Outline the expected improvements and timeline..."
          disabled={loading}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Consequences</label>
        <textarea
          required
          rows={3}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.consequences}
          onChange={(e) => setFormData({ ...formData, consequences: e.target.value })}
          placeholder="State the consequences if improvements are not made..."
          disabled={loading}
        />
      </div>

      <div className="flex justify-end space-x-3">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          disabled={loading}
        >
          {loading ? 'Saving...' : (initialData ? 'Update Warning Letter' : 'Create Warning Letter')}
        </button>
      </div>
    </form>
  );
}