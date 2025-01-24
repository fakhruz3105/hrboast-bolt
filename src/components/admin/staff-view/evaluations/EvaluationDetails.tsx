import React from 'react';
import { X } from 'lucide-react';
import { EvaluationResponse } from '../../../../types/evaluation';
import ScoreDisplay from '../../evaluation/ScoreDisplay';

type Props = {
  evaluation: EvaluationResponse;
  onClose: () => void;
};

export default function EvaluationDetails({ evaluation, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">{evaluation.evaluation?.title}</h2>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700 transition-colors"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
          </div>

          <div className="p-6">
            <div className="grid grid-cols-2 gap-6 mb-8">
              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Evaluation Details</h3>
                <dl className="grid grid-cols-2 gap-x-4 gap-y-4">
                  <div className="col-span-2">
                    <dt className="text-sm font-medium text-gray-500">Type</dt>
                    <dd className="mt-1 text-sm text-gray-900 capitalize">{evaluation.evaluation?.type}</dd>
                  </div>
                  <div className="col-span-2">
                    <dt className="text-sm font-medium text-gray-500">Manager</dt>
                    <dd className="mt-1 text-sm text-gray-900">{evaluation.manager?.name}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Status</dt>
                    <dd className="mt-1">
                      <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                        evaluation.status === 'completed'
                          ? 'bg-green-100 text-green-800'
                          : 'bg-yellow-100 text-yellow-800'
                      }`}>
                        {evaluation.status}
                      </span>
                    </dd>
                  </div>
                  {evaluation.percentage_score && (
                    <div>
                      <dt className="text-sm font-medium text-gray-500">Overall Score</dt>
                      <dd className="mt-1">
                        <ScoreDisplay percentage={evaluation.percentage_score} size="lg" />
                      </dd>
                    </div>
                  )}
                </dl>
              </div>
            </div>

            <div className="space-y-8">
              {evaluation.evaluation?.questions.map((question, index) => (
                <div key={question.id} className="bg-gray-50 p-6 rounded-lg">
                  <div className="mb-4">
                    <h4 className="text-lg font-medium text-gray-900">{question.question}</h4>
                    {question.description && (
                      <p className="mt-1 text-sm text-gray-500">{question.description}</p>
                    )}
                  </div>

                  <div className="grid grid-cols-2 gap-6">
                    <div>
                      <h5 className="text-sm font-medium text-gray-700 mb-2">Self Assessment</h5>
                      <div className="space-y-2">
                        <div>
                          <span className="text-sm text-gray-500">Rating: </span>
                          <span className="text-sm font-medium text-gray-900">
                            {evaluation.self_ratings[question.id] || 'Not rated'}
                          </span>
                        </div>
                        <div>
                          <span className="text-sm text-gray-500">Comments: </span>
                          <p className="text-sm text-gray-900 mt-1">
                            {evaluation.self_comments[question.id] || 'No comments'}
                          </p>
                        </div>
                      </div>
                    </div>

                    <div>
                      <h5 className="text-sm font-medium text-gray-700 mb-2">Manager Assessment</h5>
                      <div className="space-y-2">
                        <div>
                          <span className="text-sm text-gray-500">Rating: </span>
                          <span className="text-sm font-medium text-gray-900">
                            {evaluation.manager_ratings[question.id] || 'Not rated'}
                          </span>
                        </div>
                        <div>
                          <span className="text-sm text-gray-500">Comments: </span>
                          <p className="text-sm text-gray-900 mt-1">
                            {evaluation.manager_comments[question.id] || 'No comments'}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="px-6 py-4 border-t border-gray-200">
            <div className="flex justify-end">
              <button
                onClick={onClose}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}