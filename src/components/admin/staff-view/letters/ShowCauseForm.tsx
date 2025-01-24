import React, { useState } from 'react';

type Props = {
  letterId: string;
  onSubmit: (response: string) => Promise<void>;
  onCancel: () => void;
};

export default function ShowCauseForm({ letterId, onSubmit, onCancel }: Props) {
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!response.trim()) return;

    setLoading(true);
    try {
      await onSubmit(response);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Your Response
        </label>
        <textarea
          required
          rows={6}
          className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
          placeholder="Enter your response to this warning letter..."
          value={response}
          onChange={(e) => setResponse(e.target.value)}
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
          {loading ? 'Submitting...' : 'Submit Response'}
        </button>
      </div>
    </form>
  );
}