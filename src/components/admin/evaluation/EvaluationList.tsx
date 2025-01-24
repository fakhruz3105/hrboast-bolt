import React from 'react';
import { Eye, FileText, Trash2 } from 'lucide-react';
import { EvaluationForm } from '../../../types/evaluation';

type Props = {
  evaluations: EvaluationForm[];
  onView: (evaluation: EvaluationForm) => void;
  onStartEvaluation: (evaluation: EvaluationForm) => void;
  onDelete: (evaluation: EvaluationForm) => void;
};

export default function EvaluationList({ evaluations, onView, onStartEvaluation, onDelete }: Props) {
  const handleDelete = (evaluation: EvaluationForm) => {
    if (window.confirm('Are you sure you want to delete this evaluation form?')) {
      onDelete(evaluation);
    }
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Questions</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {evaluations.map((evaluation) => (
            <tr key={evaluation.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">{evaluation.title}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-500 capitalize">{evaluation.type}</span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-500">{evaluation.questions.length} questions</span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {new Date(evaluation.created_at || '').toLocaleDateString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                <button
                  onClick={() => onView(evaluation)}
                  className="text-indigo-600 hover:text-indigo-900 inline-flex items-center"
                  title="View Details"
                >
                  <Eye className="h-4 w-4 mr-1" />
                  View
                </button>
                <button
                  onClick={() => onStartEvaluation(evaluation)}
                  className="text-indigo-600 hover:text-indigo-900 inline-flex items-center"
                  title="Assign Evaluation"
                >
                  <FileText className="h-4 w-4 mr-1" />
                  Assign
                </button>
                <button
                  onClick={() => handleDelete(evaluation)}
                  className="text-red-600 hover:text-red-900 inline-flex items-center"
                  title="Delete Evaluation"
                >
                  <Trash2 className="h-4 w-4 mr-1" />
                  Delete
                </button>
              </td>
            </tr>
          ))}
          {evaluations.length === 0 && (
            <tr>
              <td colSpan={5} className="px-6 py-4 text-center text-sm text-gray-500">
                No evaluation forms found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}