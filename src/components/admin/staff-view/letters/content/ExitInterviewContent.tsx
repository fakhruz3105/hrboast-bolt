import React from 'react';
import { Letter } from '../../../../../types/letter';

type Props = {
  letter: Letter;
};

export default function ExitInterviewContent({ letter }: Props) {
  if (letter.content?.type !== 'exit') return null;

  const formatReason = (reason?: string) => {
    if (!reason) return '-';
    return reason.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ');
  };

  if (letter.status === 'completed' || letter.status === 'submitted') {
    return (
      <div className="space-y-4">
        <div>
          <h3 className="text-lg font-medium text-gray-900">Primary Reason</h3>
          <p className="text-gray-700">{formatReason(letter.content.reason)}</p>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">Last Working Date</h3>
          <p className="text-gray-700">
            {new Date(letter.content.lastWorkingDate).toLocaleDateString()}
          </p>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">Detailed Reason</h3>
          <p className="text-gray-700">{letter.content.detailedReason}</p>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">Suggestions</h3>
          <p className="text-gray-700">{letter.content.suggestions || 'None provided'}</p>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">Handover Notes</h3>
          <p className="text-gray-700">{letter.content.handoverNotes}</p>
        </div>
        <div>
          <h3 className="text-lg font-medium text-gray-900">Exit Checklist</h3>
          <ul className="mt-2 space-y-1">
            {Object.entries(letter.content.exitChecklist).map(([key, value]) => (
              <li key={key} className="flex items-center">
                <input
                  type="checkbox"
                  checked={value as boolean}
                  readOnly
                  className="rounded border-gray-300 text-indigo-600"
                />
                <span className="ml-2 text-gray-700">
                  {key.split(/(?=[A-Z])/).join(' ').replace(/^\w/, c => c.toUpperCase())}
                </span>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }

  return (
    <div className="text-center">
      <p className="text-gray-600">
        Exit interview form is pending completion.
      </p>
    </div>
  );
}