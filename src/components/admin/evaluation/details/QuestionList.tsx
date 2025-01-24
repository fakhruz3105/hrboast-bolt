import React from 'react';
import { EvaluationQuestion } from '../../../../types/evaluation';

type Props = {
  questions: EvaluationQuestion[];
};

export default function QuestionList({ questions }: Props) {
  return (
    <div className="space-y-4">
      {questions.map((question, index) => (
        <div key={question.id || index} className="bg-gray-50 p-4 rounded-lg">
          <div className="flex justify-between items-start mb-2">
            <div>
              <h4 className="font-medium text-gray-900">{question.question}</h4>
              <p className="text-sm text-gray-500">{question.category}</p>
            </div>
          </div>
          {question.description && (
            <p className="text-gray-600 text-sm mt-2">{question.description}</p>
          )}
        </div>
      ))}
    </div>
  );
}