import React from 'react';
import { EvaluationForm } from '../../../types/evaluation';
import EvaluationHeader from './details/EvaluationHeader';
import QuestionList from './details/QuestionList';

type Props = {
  evaluation: EvaluationForm;
  onClose: () => void;
};

export default function EvaluationDetails({ evaluation, onClose }: Props) {
  if (!evaluation) return null;

  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <EvaluationHeader
            title={evaluation.title}
            type={evaluation.type}
            createdAt={evaluation.created_at || ''}
            onClose={onClose}
          />

          <div className="p-6">
            <div className="mb-8">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Evaluation Questions</h3>
              <QuestionList questions={evaluation.questions || []} />
            </div>
          </div>

          <div className="px-6 py-4 border-t border-gray-200 flex justify-end">
            <button
              onClick={onClose}
              className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}