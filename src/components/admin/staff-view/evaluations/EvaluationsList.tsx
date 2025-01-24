import React from 'react';
import { EvaluationResponse } from '../../../../types/evaluation';
import { Eye, FileText } from 'lucide-react';
import ScoreDisplay from '../../evaluation/ScoreDisplay';

type Props = {
  evaluations: EvaluationResponse[];
  onView: (evaluation: EvaluationResponse) => void;
  onStartSelfEvaluation: (evaluation: EvaluationResponse) => void;
};

export default function EvaluationsList({ evaluations, onView, onStartSelfEvaluation }: Props) {
  const getPrimaryDepartment = (staff: any) => {
    const primaryDept = staff?.departments?.find((d: any) => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Manager</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Score</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {evaluations.map((evaluation) => (
            <tr key={evaluation.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">
                  {evaluation.evaluation?.title}
                </div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-500">
                  {evaluation.evaluation?.type}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-500">
                  {getPrimaryDepartment(evaluation.staff)}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-500">
                  {evaluation.manager?.name}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                {evaluation.percentage_score && (
                  <ScoreDisplay percentage={evaluation.percentage_score} />
                )}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                  evaluation.status === 'completed'
                    ? 'bg-green-100 text-green-800'
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {evaluation.status}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                {evaluation.status === 'pending' ? (
                  <button
                    onClick={() => onStartSelfEvaluation(evaluation)}
                    className="text-indigo-600 hover:text-indigo-900 inline-flex items-center"
                  >
                    <FileText className="h-4 w-4 mr-1" />
                    Start Evaluation
                  </button>
                ) : (
                  <button
                    onClick={() => onView(evaluation)}
                    className="text-indigo-600 hover:text-indigo-900 inline-flex items-center"
                  >
                    <Eye className="h-4 w-4 mr-1" />
                    View
                  </button>
                )}
              </td>
            </tr>
          ))}
          {evaluations.length === 0 && (
            <tr>
              <td colSpan={7} className="px-6 py-4 text-center text-sm text-gray-500">
                No evaluations found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}