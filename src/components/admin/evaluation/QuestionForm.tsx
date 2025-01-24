import React from 'react';
import { Plus, Trash2 } from 'lucide-react';
import { QuestionType } from '../../../types/evaluation';
import CategorySelector from './CategorySelector';

type Props = {
  question: {
    id: string;
    category: string;
    question: string;
    description?: string;
    type: QuestionType;
    options?: string[];
  };
  onUpdate: (field: string, value: any) => void;
  onDelete: () => void;
};

export default function QuestionForm({ question, onUpdate, onDelete }: Props) {
  const handleOptionAdd = () => {
    const options = [...(question.options || []), ''];
    onUpdate('options', options);
  };

  const handleOptionUpdate = (index: number, value: string) => {
    const options = [...(question.options || [])];
    options[index] = value;
    onUpdate('options', options);
  };

  const handleOptionDelete = (index: number) => {
    const options = [...(question.options || [])];
    options.splice(index, 1);
    onUpdate('options', options);
  };

  return (
    <div className="bg-gray-50 p-4 rounded-lg space-y-4">
      <div className="flex justify-between items-start">
        <div className="flex-1 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Category</label>
            <input
              type="text"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={question.category}
              onChange={(e) => onUpdate('category', e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Question</label>
            <input
              type="text"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={question.question}
              onChange={(e) => onUpdate('question', e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Description</label>
            <textarea
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={question.description || ''}
              onChange={(e) => onUpdate('description', e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700">Question Type</label>
            <select
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={question.type}
              onChange={(e) => onUpdate('type', e.target.value)}
            >
              <option value="rating">Rating Scale (1-5)</option>
              <option value="checkbox">Checkbox List</option>
              <option value="text">Text Response</option>
            </select>
          </div>

          {question.type === 'checkbox' && (
            <div className="space-y-2">
              <label className="block text-sm font-medium text-gray-700">Options</label>
              {question.options?.map((option, index) => (
                <div key={index} className="flex items-center gap-2">
                  <input
                    type="text"
                    required
                    className="flex-1 rounded-md border border-gray-300 px-3 py-2"
                    value={option}
                    onChange={(e) => handleOptionUpdate(index, e.target.value)}
                    placeholder={`Option ${index + 1}`}
                  />
                  <button
                    type="button"
                    onClick={() => handleOptionDelete(index)}
                    className="text-red-600 hover:text-red-800"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              ))}
              <button
                type="button"
                onClick={handleOptionAdd}
                className="inline-flex items-center text-sm text-indigo-600 hover:text-indigo-800"
              >
                <Plus className="h-4 w-4 mr-1" />
                Add Option
              </button>
            </div>
          )}
        </div>
        <button
          type="button"
          onClick={onDelete}
          className="text-red-600 hover:text-red-800 ml-4"
        >
          <Trash2 className="h-5 w-5" />
        </button>
      </div>
    </div>
  );
}