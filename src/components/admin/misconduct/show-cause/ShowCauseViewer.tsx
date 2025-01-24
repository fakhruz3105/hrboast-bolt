import React from 'react';
import { X } from 'lucide-react';
import { ShowCauseLetter } from '../../../../types/showCause';

type Props = {
  letter: ShowCauseLetter;
  onClose: () => void;
};

const TYPE_LABELS: Record<string, string> = {
  lateness: 'Lateness',
  harassment: 'Harassment',
  leave_without_approval: 'Leave without Approval',
  offensive_behavior: 'Offensive Behavior',
  insubordination: 'Insubordination',
  misconduct: 'Other Misconduct'
};

export default function ShowCauseViewer({ letter, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Show Cause Letter</h2>
                <p className="text-gray-600 mt-1">
                  {letter.staff?.name} - {letter.staff?.departments?.[0]?.department?.name}
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
              <div>
                <h3 className="text-lg font-medium text-gray-900">Type</h3>
                <p className="text-gray-700">
                  {TYPE_LABELS[letter.content?.type] || letter.content?.title}
                </p>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900">Incident Date</h3>
                <p className="text-gray-700">
                  {new Date(letter.content?.incident_date).toLocaleDateString()}
                </p>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900">Description</h3>
                <p className="text-gray-700 whitespace-pre-wrap">{letter.content?.description}</p>
              </div>

              {letter.content?.response && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Staff Response</h3>
                  <div className="text-sm text-gray-500 mb-2">
                    Submitted on {new Date(letter.content.response_date).toLocaleDateString()}
                  </div>
                  <p className="text-gray-700 whitespace-pre-wrap">{letter.content.response}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}