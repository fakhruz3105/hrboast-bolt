import React from 'react';
import { defaultEvaluationCategories } from '../../../utils/evaluationCategories';

type Props = {
  selectedCategories: string[];
  onSelectCategory: (categoryId: string) => void;
};

export default function CategorySelector({ selectedCategories, onSelectCategory }: Props) {
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-medium text-gray-900">Evaluation Categories</h3>
      <div className="grid grid-cols-2 gap-4">
        {defaultEvaluationCategories.map((category) => (
          <button
            key={category.id}
            type="button"
            onClick={() => onSelectCategory(category.id)}
            className={`p-4 text-left rounded-lg border transition-colors ${
              selectedCategories.includes(category.id)
                ? 'border-indigo-500 bg-indigo-50'
                : 'border-gray-200 hover:border-indigo-300'
            }`}
          >
            <h4 className="text-sm font-medium text-gray-900">{category.name}</h4>
            <p className="mt-1 text-sm text-gray-500">
              {category.questions.length} questions
            </p>
          </button>
        ))}
      </div>
    </div>
  );
}