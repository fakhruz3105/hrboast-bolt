import React from 'react';
import { EvaluationResponse } from '../../../types/evaluation';
import { Eye, FileText, Trash2, Download } from 'lucide-react';
import ScoreDisplay from './ScoreDisplay';
import { generateEvaluationReportPDF } from '../../../utils/evaluationReportPDF';
import { toast } from 'react-hot-toast';

type Props = {
  company: string;
  assignments: EvaluationResponse[];
  onView: (evaluation: EvaluationResponse) => void;
  onDelete?: (evaluation: EvaluationResponse) => void;
};

export default function AssignedEvaluationsList({ company, assignments, onView, onDelete }: Props) {
  const handleDelete = (assignment: EvaluationResponse) => {
    if (window.confirm('Are you sure you want to delete this evaluation assignment?')) {
      onDelete?.(assignment);
    }
  };

  const handleDownload = async (evaluation: EvaluationResponse) => {
    try {
      if (evaluation.status !== 'completed') {
        toast.error('Only completed evaluations can be downloaded');
        return;
      }
      generateEvaluationReportPDF(company, evaluation);
      toast.success('Evaluation report downloaded successfully');
    } catch (error) {
      console.error('Error downloading evaluation report:', error);
      toast.error('Failed to download evaluation report');
    }
  };

  const getEvaluationStatus = (evaluation: EvaluationResponse) => {
    const hasStaffEvaluation = Object.keys(evaluation.self_ratings).length > 0;
    const hasManagerEvaluation = Object.keys(evaluation.manager_ratings).length > 0;

    if (hasStaffEvaluation && hasManagerEvaluation) {
      return {
        label: 'Completed',
        color: 'bg-green-100 text-green-800'
      };
    } else if (hasStaffEvaluation && !hasManagerEvaluation) {
      return {
        label: 'Pending Manager',
        color: 'bg-yellow-100 text-yellow-800'
      };
    } else if (!hasStaffEvaluation && hasManagerEvaluation) {
      return {
        label: 'Pending Staff',
        color: 'bg-orange-100 text-orange-800'
      };
    } else {
      return {
        label: 'Pending',
        color: 'bg-gray-100 text-gray-800'
      };
    }
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Evaluation</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Manager</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Score</th>
            <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {assignments.map((assignment) => {
            const status = getEvaluationStatus(assignment);
            return (
              <tr key={assignment.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">
                    {assignment.staff?.name}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-500">
                    {assignment.staff?.departments?.find(d => d.is_primary)?.department?.name}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{assignment.evaluation?.title}</div>
                  <div className="text-xs text-gray-500 capitalize">{assignment.evaluation?.type}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-500">
                    {assignment.manager?.name}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${status.color}`}>
                    {status.label}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  {assignment.percentage_score && (
                    <ScoreDisplay percentage={assignment.percentage_score} />
                  )}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end space-x-3">
                    <button
                      onClick={() => onView(assignment)}
                      className="text-indigo-600 hover:text-indigo-900 inline-flex items-center"
                      title="View Details"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                    {status.label === 'Completed' && (
                      <button
                        onClick={() => handleDownload(assignment)}
                        className="text-green-600 hover:text-green-900 inline-flex items-center"
                        title="Download Report"
                      >
                        <Download className="h-4 w-4" />
                      </button>
                    )}
                    {onDelete && (
                      <button
                        onClick={() => handleDelete(assignment)}
                        className="text-red-600 hover:text-red-900 inline-flex items-center"
                        title="Delete"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                </td>
              </tr>
            );
          })}
          {assignments.length === 0 && (
            <tr>
              <td colSpan={7} className="px-6 py-4 text-center text-sm text-gray-500">
                No evaluations assigned
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}