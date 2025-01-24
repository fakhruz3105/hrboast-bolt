import React from 'react';
import { X } from 'lucide-react';

type Props = {
  interview: {
    id: string;
    staff_id: string;
    title: string;
    content: {
      type: string;
      status: string;
      reason?: string;
      lastWorkingDate?: string;
      detailedReason?: string;
      suggestions?: string;
      handoverNotes?: string;
      exitChecklist?: Record<string, boolean>;
    };
    status: string;
    issued_date: string;
    staff_name: string;
    department_name: string;
  };
  onClose: () => void;
};

export default function ExitInterviewViewer({ interview, onClose }: Props) {
  const formatReason = (reason?: string) => {
    if (!reason) return '-';
    return reason.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ');
  };

  if (!interview) {
    return null;
  }

  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Exit Interview Details</h2>
                <p className="text-gray-600 mt-1">
                  {interview.staff_name} - {interview.department_name}
                </p>
              </div>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="space-y-6">
              {interview.content?.reason && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Primary Reason</h3>
                  <p className="text-gray-700">{formatReason(interview.content.reason)}</p>
                </div>
              )}

              {interview.content?.lastWorkingDate && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Last Working Date</h3>
                  <p className="text-gray-700">
                    {new Date(interview.content.lastWorkingDate).toLocaleDateString()}
                  </p>
                </div>
              )}

              {interview.content?.detailedReason && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Detailed Reason</h3>
                  <p className="text-gray-700 whitespace-pre-wrap">{interview.content.detailedReason}</p>
                </div>
              )}

              {interview.content?.suggestions && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Suggestions</h3>
                  <p className="text-gray-700 whitespace-pre-wrap">{interview.content.suggestions}</p>
                </div>
              )}

              {interview.content?.handoverNotes && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Handover Notes</h3>
                  <p className="text-gray-700 whitespace-pre-wrap">{interview.content.handoverNotes}</p>
                </div>
              )}

              {interview.content?.exitChecklist && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Exit Checklist</h3>
                  <div className="mt-4 space-y-2">
                    {Object.entries(interview.content.exitChecklist).map(([key, value]) => (
                      <div key={key} className="flex items-center">
                        <input
                          type="checkbox"
                          checked={value}
                          readOnly
                          className="h-4 w-4 text-indigo-600 border-gray-300 rounded"
                        />
                        <span className="ml-3 text-gray-700">
                          {key.split(/(?=[A-Z])/).join(' ').replace(/^\w/, c => c.toUpperCase())}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Status */}
              <div className="mt-6 pt-6 border-t border-gray-200">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-gray-500">Status</span>
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    interview.status === 'submitted' 
                      ? 'bg-green-100 text-green-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {interview.status.charAt(0).toUpperCase() + interview.status.slice(1)}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}