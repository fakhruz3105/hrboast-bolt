import React from 'react';
import { EvaluationQuestion } from '../../../utils/evaluationCategories';
import { Trash2 } from 'lucide-react';

type Props = {
  questions: EvaluationQuestion[];
  onRemoveQuestion: (questionId: string) => void;
};

export default function QuestionList({ questions, onRemoveQuestion }: Props) {
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-medium text-gray-900">Selected Questions</h3>
      {questions.map((question) => (
        <div 
          key={question.id}
          className="flex items-start justify-between p-4 bg-white rounded-lg border border-gray-200"
        >
          <div className="flex-1">
            <h4 className="text-sm font-medium text-gray-900">{question.question}</h4>
            <p className="mt-1 text-sm text-gray-500">{question.description}</p>
            <div className="mt-2">
              <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                {question.type}
              </span>
            </div>
          </div>
          <button
            type="button"
            onClick={() => onRemoveQuestion(question.id)}
            className="ml-4 text-gray-400 hover:text-red-500"
          >
            <Trash2 className="h-5 w-5" />
          </button>
        </div>
      ))}
      {questions.length === 0 && (
        <p className="text-sm text-gray-500 text-center py-4">
          No questions selected. Choose categories above to add questions.
        </p>
      )}
    </div>
  );
}