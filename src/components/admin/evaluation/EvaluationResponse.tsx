import React, { useState } from 'react';
import { Rating, EvaluationQuestion } from '../../../types/evaluation';

type Props = {
  questions: EvaluationQuestion[];
  onSubmit: (ratings: Record<string, Rating>, comments: Record<string, string>) => Promise<void>;
  isSelfEvaluation?: boolean;
};

export default function EvaluationResponse({ questions, onSubmit, isSelfEvaluation = true }: Props) {
  const [ratings, setRatings] = useState<Record<string, Rating>>({});
  const [comments, setComments] = useState<Record<string, string>>({});

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await onSubmit(ratings, comments);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {questions.map((question) => (
        <div key={question.id} className="bg-white p-6 rounded-lg shadow">
          <div className="mb-4">
            <h3 className="text-lg font-medium text-gray-900">{question.question}</h3>
            <p className="text-sm text-gray-500">{question.description}</p>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Rating</label>
              <div className="flex space-x-4">
                {[1, 2, 3, 4, 5].map((value) => (
                  <label key={value} className="flex items-center">
                    <input
                      type="radio"
                      name={`rating-${question.id}`}
                      value={value}
                      checked={ratings[question.id] === value}
                      onChange={() => setRatings({ ...ratings, [question.id]: value as Rating })}
                      className="mr-2"
                      required
                    />
                    <span>{value}</span>
                  </label>
                ))}
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Comments</label>
              <textarea
                rows={3}
                className="w-full rounded-md border border-gray-300 px-3 py-2"
                value={comments[question.id] || ''}
                onChange={(e) => setComments({ ...comments, [question.id]: e.target.value })}
                required
              />
            </div>
          </div>
        </div>
      ))}

      <div className="flex justify-end">
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          Submit {isSelfEvaluation ? 'Self-Evaluation' : 'Manager Evaluation'}
        </button>
      </div>
    </form>
  );
}