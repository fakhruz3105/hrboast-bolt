import React from 'react';
import { X } from 'lucide-react';
import { EvaluationResponse } from '../../../../types/evaluation';
import ScoreDisplay from '../ScoreDisplay';
import ResponseHeader from './ResponseHeader';
import ResponseQuestions from './ResponseQuestions';

type Props = {
  evaluation: EvaluationResponse;
  onClose: () => void;
};

export default function EvaluationResponseDetails({ evaluation, onClose }: Props) {
  if (!evaluation?.evaluation) return null;

  return (
    <div className="fixed inset-0 bg-black/50 z-[100] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <ResponseHeader 
            title={evaluation.evaluation.title}
            type={evaluation.evaluation.type}
            staff={evaluation.staff}
            manager={evaluation.manager}
            status={evaluation.status}
            score={evaluation.percentage_score}
            onClose={onClose}
          />

          <div className="p-6">
            <ResponseQuestions 
              questions={evaluation.evaluation.questions}
              selfRatings={evaluation.self_ratings}
              selfComments={evaluation.self_comments}
              managerRatings={evaluation.manager_ratings}
              managerComments={evaluation.manager_comments}
            />
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