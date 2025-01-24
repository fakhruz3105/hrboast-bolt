import React, { useState, useEffect } from 'react';
import { EvaluationType } from '../../../types/evaluation';
import QuestionList from './QuestionList';
import { defaultEvaluationCategories, managerEvaluationCategories, getEvaluationCategories } from '../../../utils/evaluationCategories';
import { Plus, Check } from 'lucide-react';

type Props = {
  onSubmit: (data: {
    title: string;
    type: EvaluationType;
    questions: Array<{
      id: string;
      category: string;
      question: string;
      description?: string;
      type: 'rating' | 'checkbox' | 'text';
      options?: string[];
    }>;
  }) => Promise<void>;
};

export default function EvaluationForm({ onSubmit }: Props) {
  const [formData, setFormData] = useState({
    title: '',
    type: 'quarter' as EvaluationType,
    questions: [] // Start with no questions selected
  });

  const [showCustomForm, setShowCustomForm] = useState(false);
  const [customQuestion, setCustomQuestion] = useState({
    category: '',
    question: '',
    description: '',
    type: 'rating' as const
  });

  // Track selected categories
  const [selectedCategories, setSelectedCategories] = useState<Set<string>>(new Set());
  const [selectedLevel, setSelectedLevel] = useState<string>('Staff');

  // Get categories based on selected level
  const categories = getEvaluationCategories(selectedLevel);

  const toggleCategory = (categoryId: string) => {
    const newSelectedCategories = new Set(selectedCategories);
    if (newSelectedCategories.has(categoryId)) {
      newSelectedCategories.delete(categoryId);
    } else {
      newSelectedCategories.add(categoryId);
    }
    setSelectedCategories(newSelectedCategories);

    // Update questions based on selected categories
    const selectedQuestions = categories
      .filter(category => newSelectedCategories.has(category.id))
      .flatMap(category => category.questions);

    setFormData(prev => ({
      ...prev,
      questions: [...selectedQuestions, ...prev.questions.filter(q => q.id.startsWith('custom-'))]
    }));
  };

  const addCustomQuestion = () => {
    const newQuestion = {
      ...customQuestion,
      id: `custom-${Date.now()}` // Generate a unique ID
    };
    
    // Add to formData questions
    setFormData(prev => ({
      ...prev,
      questions: [...prev.questions, newQuestion]
    }));
    
    // Reset form
    setCustomQuestion({
      category: '',
      question: '',
      description: '',
      type: 'rating'
    });
    setShowCustomForm(false);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (formData.questions.length === 0) {
      alert('Please select at least one category or add custom questions');
      return;
    }
    await onSubmit(formData);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      <div className="grid grid-cols-2 gap-6">
        <div className="col-span-2">
          <label className="block text-sm font-medium text-gray-700">Form Title</label>
          <input
            type="text"
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.title}
            onChange={(e) => setFormData({ ...formData, title: e.target.value })}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Evaluation Type</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.type}
            onChange={(e) => setFormData({ ...formData, type: e.target.value as EvaluationType })}
          >
            <option value="quarter">Quarter</option>
            <option value="half-year">Half Year</option>
            <option value="yearly">Yearly</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Staff Level</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={selectedLevel}
            onChange={(e) => {
              setSelectedLevel(e.target.value);
              setSelectedCategories(new Set());
              setFormData(prev => ({ ...prev, questions: [] }));
            }}
          >
            <option value="Staff">Staff</option>
            <option value="HOD/Manager">HOD/Manager</option>
            <option value="C-Suite">C-Suite</option>
          </select>
        </div>
      </div>

      <div className="border-t border-gray-200 pt-8">
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-lg font-medium text-gray-900">Questions</h3>
          <button
            type="button"
            onClick={() => setShowCustomForm(true)}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-indigo-600 bg-indigo-100 hover:bg-indigo-200"
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Custom Question
          </button>
        </div>

        {showCustomForm && (
          <div className="mb-6 bg-gray-50 p-4 rounded-lg">
            <h4 className="text-sm font-medium text-gray-900 mb-4">Add Custom Question</h4>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Category</label>
                <input
                  type="text"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={customQuestion.category}
                  onChange={(e) => setCustomQuestion({ ...customQuestion, category: e.target.value })}
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Question</label>
                <input
                  type="text"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={customQuestion.question}
                  onChange={(e) => setCustomQuestion({ ...customQuestion, question: e.target.value })}
                  required
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={customQuestion.description}
                  onChange={(e) => setCustomQuestion({ ...customQuestion, description: e.target.value })}
                />
              </div>
              
              <div>
                <label className="block text-sm font-medium text-gray-700">Question Type</label>
                <select
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={customQuestion.type}
                  onChange={(e) => setCustomQuestion({ ...customQuestion, type: e.target.value as 'rating' | 'checkbox' | 'text' })}
                >
                  <option value="rating">Rating Scale (1-5)</option>
                  <option value="text">Text Response</option>
                </select>
              </div>

              <div className="flex justify-end space-x-3">
                <button
                  type="button"
                  onClick={() => setShowCustomForm(false)}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="button"
                  onClick={addCustomQuestion}
                  className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                >
                  Add Question
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Available Categories */}
        <div className="space-y-4">
          {categories.map((category) => (
            <div key={category.id} className="bg-gray-50 p-4 rounded-lg">
              <div className="flex items-start space-x-4">
                <button
                  type="button"
                  onClick={() => toggleCategory(category.id)}
                  className={`flex items-center justify-center h-6 w-6 rounded border ${
                    selectedCategories.has(category.id)
                      ? 'bg-indigo-600 border-indigo-600 text-white'
                      : 'border-gray-300 hover:border-indigo-500'
                  }`}
                >
                  {selectedCategories.has(category.id) && <Check className="h-4 w-4" />}
                </button>
                <div className="flex-1">
                  <h4 className="text-lg font-medium text-gray-900">{category.name}</h4>
                  <p className="text-sm text-gray-500 mt-1">{category.questions.length} questions</p>
                  
                  {/* Show questions if category is selected */}
                  {selectedCategories.has(category.id) && (
                    <div className="mt-4 space-y-4">
                      {category.questions.map((question) => (
                        <div key={question.id} className="bg-white p-4 rounded-lg">
                          <h5 className="text-sm font-medium text-gray-900">{question.question}</h5>
                          {question.description && (
                            <p className="mt-1 text-sm text-gray-500">{question.description}</p>
                          )}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Custom Questions Section */}
        {formData.questions.filter(q => q.id.startsWith('custom-')).length > 0 && (
          <div className="mt-8">
            <h4 className="text-lg font-medium text-gray-900 mb-4">Custom Questions</h4>
            <div className="space-y-4">
              {formData.questions
                .filter(q => q.id.startsWith('custom-'))
                .map((question) => (
                  <div key={question.id} className="bg-white p-4 rounded-lg border border-gray-200">
                    <div className="flex justify-between">
                      <div>
                        <h5 className="text-sm font-medium text-gray-900">{question.question}</h5>
                        {question.description && (
                          <p className="mt-1 text-sm text-gray-500">{question.description}</p>
                        )}
                        <p className="text-xs text-gray-400 mt-2">Category: {question.category}</p>
                      </div>
                      <button
                        type="button"
                        onClick={() => setFormData(prev => ({
                          ...prev,
                          questions: prev.questions.filter(q => q.id !== question.id)
                        }))}
                        className="text-red-600 hover:text-red-800"
                      >
                        Remove
                      </button>
                    </div>
                  </div>
                ))}
            </div>
          </div>
        )}
      </div>

      <div className="flex justify-end pt-6">
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          Create Evaluation Form
        </button>
      </div>
    </form>
  );
}