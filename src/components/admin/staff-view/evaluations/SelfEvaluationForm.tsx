import React, { useState } from 'react';
import { X } from 'lucide-react';
import { EvaluationResponse } from '../../../../types/evaluation';
import RatingInput from '../../evaluation/RatingInput';

type Props = {
  evaluation: EvaluationResponse;
  onSubmit: (responses: Record<string, any>) => Promise<void>;
  onClose: () => void;
};

export default function SelfEvaluationForm({ evaluation, onSubmit, onClose }: Props) {
  const [ratings, setRatings] = useState<Record<string, number>>({});
  const [overallComments, setOverallComments] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!evaluation.evaluation?.questions) return;

    // Validate all questions have ratings
    const missingRatings = evaluation.evaluation.questions.some(
      q => !ratings[q.id]
    );

    if (missingRatings) {
      alert('Please provide ratings for all questions');
      return;
    }

    setLoading(true);
    try {
      await onSubmit({
        ratings,
        comments: { overall: overallComments }
      });
    } catch (error) {
      console.error('Error submitting evaluation:', error);
      alert('Failed to submit evaluation');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-[100] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Self Evaluation</h2>
                <p className="mt-1 text-sm text-gray-600">{evaluation.evaluation?.title}</p>
              </div>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="p-6">
            <div className="space-y-6">
              {evaluation.evaluation?.questions.map((question) => (
                <div key={question.id} className="bg-white p-6 rounded-lg shadow">
                  <div className="mb-4">
                    <h3 className="text-lg font-medium text-gray-900">{question.question}</h3>
                    {question.description && (
                      <p className="mt-1 text-sm text-gray-500">{question.description}</p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">Rating</label>
                    <RatingInput
                      value={ratings[question.id] || null}
                      onChange={(rating) => setRatings(prev => ({ ...prev, [question.id]: rating }))}
                      required
                    />
                  </div>
                </div>
              ))}

              {/* Overall Comments Section */}
              <div className="bg-white p-6 rounded-lg shadow">
                <label className="block text-lg font-medium text-gray-900 mb-4">
                  Overall Comments
                </label>
                <textarea
                  required
                  rows={5}
                  className="w-full rounded-md border border-gray-300 px-3 py-2"
                  value={overallComments}
                  onChange={(e) => setOverallComments(e.target.value)}
                  placeholder="Provide your overall comments and reflections..."
                />
              </div>
            </div>

            <div className="flex justify-end space-x-3 mt-6">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200"
                disabled={loading}
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
                disabled={loading}
              >
                {loading ? 'Submitting...' : 'Submit Evaluation'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}