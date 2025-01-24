import React from 'react';
import { EvaluationQuestion } from '../../../../types/evaluation';

type Props = {
  questions: EvaluationQuestion[];
  selfRatings: Record<string, number>;
  selfComments: Record<string, string>;
  managerRatings: Record<string, number>;
  managerComments: Record<string, string>;
};

export default function ResponseQuestions({ 
  questions,
  selfRatings,
  selfComments,
  managerRatings,
  managerComments
}: Props) {
  return (
    <div className="space-y-6">
      {/* Questions and Ratings */}
      <div className="space-y-4">
        {questions.map((question) => (
          <div key={question.id} className="bg-gray-50 p-6 rounded-lg">
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gray-900">{question.question}</h4>
              {question.description && (
                <p className="mt-1 text-sm text-gray-500">{question.description}</p>
              )}
            </div>

            <div className="grid grid-cols-2 gap-6">
              <div>
                <h5 className="text-sm font-medium text-gray-700 mb-2">Self Rating</h5>
                <span className="text-sm font-medium text-gray-900">
                  {selfRatings[question.id] || 'Not rated'}
                </span>
              </div>

              <div>
                <h5 className="text-sm font-medium text-gray-700 mb-2">Manager Rating</h5>
                <span className="text-sm font-medium text-gray-900">
                  {managerRatings[question.id] || 'Not rated'}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Overall Comments */}
      <div className="space-y-6 mt-8">
        <div className="bg-white p-6 rounded-lg border border-gray-200">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Overall Comments</h3>
          
          <div className="grid grid-cols-2 gap-6">
            <div>
              <h4 className="text-sm font-medium text-gray-700 mb-2">Self Assessment Comments</h4>
              <p className="text-sm text-gray-900 whitespace-pre-wrap">
                {selfComments['overall'] || 'No comments provided'}
              </p>
            </div>

            <div>
              <h4 className="text-sm font-medium text-gray-700 mb-2">Manager Comments</h4>
              <p className="text-sm text-gray-900 whitespace-pre-wrap">
                {managerComments['overall'] || 'No comments provided'}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}