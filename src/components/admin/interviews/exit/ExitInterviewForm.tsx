import React, { useState } from 'react';
import { ExitInterviewFormData } from '../../../../types/exitInterview';

type Props = {
  onSubmit: (data: ExitInterviewFormData) => Promise<void>;
  onCancel: () => void;
};

export default function ExitInterviewForm({ onSubmit, onCancel }: Props) {
  const [formData, setFormData] = useState<ExitInterviewFormData>({
    staff_id: '',
    reason: '',
    detailedReason: '',
    lastWorkingDate: '',
    suggestions: '',
    handoverNotes: '',
    exitChecklist: {
      returnedLaptop: false,
      returnedAccessCard: false,
      completedHandover: false,
      clearedDues: false
    }
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700">Primary Reason for Leaving</label>
        <select
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.reason}
          onChange={(e) => setFormData({ ...formData, reason: e.target.value })}
        >
          <option value="">Select a reason</option>
          <option value="better_opportunity">Better Opportunity</option>
          <option value="career_change">Career Change</option>
          <option value="relocation">Relocation</option>
          <option value="work_environment">Work Environment</option>
          <option value="compensation">Compensation</option>
          <option value="personal">Personal Reasons</option>
          <option value="other">Other</option>
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Last Working Date</label>
        <input
          type="date"
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.lastWorkingDate}
          onChange={(e) => setFormData({ ...formData, lastWorkingDate: e.target.value })}
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Detailed Reason</label>
        <textarea
          required
          rows={4}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.detailedReason}
          onChange={(e) => setFormData({ ...formData, detailedReason: e.target.value })}
          placeholder="Please provide more details about your reason for leaving..."
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Suggestions for Improvement</label>
        <textarea
          rows={3}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.suggestions}
          onChange={(e) => setFormData({ ...formData, suggestions: e.target.value })}
          placeholder="Any suggestions for improving the workplace..."
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Handover Notes</label>
        <textarea
          required
          rows={3}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.handoverNotes}
          onChange={(e) => setFormData({ ...formData, handoverNotes: e.target.value })}
          placeholder="Details about ongoing projects, responsibilities, and handover plans..."
        />
      </div>

      <div>
        <h4 className="text-sm font-medium text-gray-700 mb-3">Exit Checklist</h4>
        <div className="space-y-2">
          {Object.entries(formData.exitChecklist).map(([key, value]) => (
            <label key={key} className="flex items-center">
              <input
                type="checkbox"
                className="rounded border-gray-300 text-indigo-600 mr-2"
                checked={value}
                onChange={(e) => setFormData({
                  ...formData,
                  exitChecklist: {
                    ...formData.exitChecklist,
                    [key]: e.target.checked
                  }
                })}
              />
              <span className="text-sm text-gray-700">
                {key.split(/(?=[A-Z])/).join(' ').replace(/^\w/, c => c.toUpperCase())}
              </span>
            </label>
          ))}
        </div>
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
          Submit Exit Interview
        </button>
      </div>
    </form>
  );
}