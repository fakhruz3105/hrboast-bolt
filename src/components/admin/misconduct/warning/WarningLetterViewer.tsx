import React from 'react';
import { X } from 'lucide-react';

type Props = {
  letter: {
    id: string;
    staff_id: string;
    title: string;
    content: {
      warning_level?: string;
      incident_date?: string;
      description?: string;
      improvement_plan?: string;
      consequences?: string;
      response?: string;
      response_date?: string;
    };
    status: string;
    issued_date: string;
    staff?: {
      name: string;
      departments?: Array<{
        is_primary: boolean;
        department: {
          name: string;
        };
      }>;
    };
  };
  onClose: () => void;
};

export default function WarningLetterViewer({ letter, onClose }: Props) {
  const getPrimaryDepartment = () => {
    if (!letter.staff?.departments) return 'N/A';
    const primaryDept = letter.staff.departments.find(d => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const getWarningLevelText = () => {
    const level = letter.content?.warning_level;
    if (!level) return 'N/A';
    return `${level.toUpperCase()} WARNING`;
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">
                  {getWarningLevelText()}
                </h2>
                <p className="text-gray-600 mt-1">
                  {letter.staff?.name} - {getPrimaryDepartment()}
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
                <h3 className="text-lg font-medium text-gray-900 mb-2">Incident Details</h3>
                <p className="text-gray-600">
                  Date: {letter.content?.incident_date ? new Date(letter.content.incident_date).toLocaleDateString() : 'N/A'}
                </p>
                <p className="mt-2 text-gray-700 whitespace-pre-wrap">{letter.content?.description}</p>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">Required Improvements</h3>
                <p className="text-gray-700 whitespace-pre-wrap">{letter.content?.improvement_plan}</p>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-2">Consequences</h3>
                <p className="text-gray-700 whitespace-pre-wrap">{letter.content?.consequences}</p>
              </div>

              {letter.content?.response && (
                <div className="bg-gray-50 rounded-lg p-4">
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Employee Response</h3>
                  {letter.content.response_date && (
                    <div className="text-sm text-gray-500 mb-2">
                      Submitted on {new Date(letter.content.response_date).toLocaleDateString()}
                    </div>
                  )}
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