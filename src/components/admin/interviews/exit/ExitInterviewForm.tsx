import React, { useState } from 'react';
import { useSupabase } from '../../../../providers/SupabaseProvider';

type Props = {
  letterId: string;
  staffId: string;
  onSubmit: () => void;
  onCancel: () => void;
};

export default function ExitInterviewForm({ letterId, staffId, onSubmit, onCancel }: Props) {
  const supabase = useSupabase();
  const [formData, setFormData] = useState({
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
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      // Update HR letter with exit interview response
      const { error: letterError } = await supabase
        .from('hr_letters')
        .update({
          content: {
            type: 'exit',
            ...formData,
            status: 'completed'
          },
          status: 'submitted'
        })
        .eq('id', letterId);

      if (letterError) throw letterError;

      // Update staff status to resigned
      const { error: staffError } = await supabase
        .from('staff')
        .update({ status: 'resigned' })
        .eq('id', staffId);

      if (staffError) throw staffError;

      onSubmit();
    } catch (error) {
      console.error('Error submitting exit interview:', error);
      alert('Failed to submit exit interview');
    } finally {
      setLoading(false);
    }
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
          disabled={loading}
          className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
        >
          Cancel
        </button>
        <button
          type="submit"
          disabled={loading}
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
        >
          {loading ? 'Submitting...' : 'Submit Exit Interview'}
        </button>
      </div>
    </form>
  );
}