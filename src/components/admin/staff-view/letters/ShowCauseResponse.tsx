import React, { useState } from 'react';
import { Letter } from '../../../../types/letter';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../../providers/SupabaseProvider';

type Props = {
  letter: Letter;
  onSubmit: () => void;
};

export default function ShowCauseResponse({ letter, onSubmit }: Props) {
  const supabase = useSupabase();
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!response.trim()) return;

    setLoading(true);
    try {
      const { error } = await supabase.rpc('submit_show_cause_response', {
        p_letter_id: letter.id,
        p_response: response
      });

      if (error) throw error;

      toast.success('Response submitted successfully');
      onSubmit();
    } catch (error) {
      console.error('Error submitting response:', error);
      toast.error('Failed to submit response');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700">
          Your Response
        </label>
        <textarea
          required
          rows={6}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={response}
          onChange={(e) => setResponse(e.target.value)}
          placeholder="Provide your response to this show cause letter..."
          disabled={loading}
        />
      </div>

      <div className="flex justify-end">
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