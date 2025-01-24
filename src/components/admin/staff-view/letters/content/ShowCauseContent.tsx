import React from 'react';
import { Letter } from '../../../../../types/letter';
import ShowCauseResponse from '../ShowCauseResponse';

type Props = {
  letter: Letter;
  onSubmitResponse?: () => void;
};

const TYPE_LABELS: Record<string, string> = {
  lateness: 'Lateness',
  harassment: 'Harassment',
  leave_without_approval: 'Leave without Approval',
  offensive_behavior: 'Offensive Behavior',
  insubordination: 'Insubordination',
  misconduct: 'Other Misconduct'
};

export default function ShowCauseContent({ letter, onSubmitResponse }: Props) {
  if (letter.type !== 'show_cause') return null;

  const showCauseData = letter.content;
  if (!showCauseData) return null;

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900">Type</h3>
        <p className="text-gray-700">
          {TYPE_LABELS[showCauseData.type] || showCauseData.title}
        </p>
      </div>

      <div>
        <h3 className="text-lg font-medium text-gray-900">Incident Date</h3>
        <p className="text-gray-700">
          {new Date(showCauseData.incident_date).toLocaleDateString()}
        </p>
      </div>

      <div>
        <h3 className="text-lg font-medium text-gray-900">Description</h3>
        <p className="text-gray-700 whitespace-pre-wrap">{showCauseData.description}</p>
      </div>

      {showCauseData.response ? (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-lg font-medium text-gray-900 mb-2">Your Response</h3>
          <div className="text-sm text-gray-500 mb-2">
            Submitted on {new Date(showCauseData.response_date).toLocaleDateString()}
          </div>
          <p className="text-gray-700 whitespace-pre-wrap">{showCauseData.response}</p>
        </div>
      ) : onSubmitResponse && (
        <div className="bg-gray-50 rounded-lg p-4">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Submit Response</h3>
          <ShowCauseResponse 
            letter={letter} 
            onSubmit={onSubmitResponse}
          />
        </div>
      )}
    </div>
  );
}