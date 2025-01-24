import React, { useState } from 'react';
import { Letter } from '../../../../../types/letter';
import ShowCauseForm from '../ShowCauseForm';
import ShowCauseResponse from '../ShowCauseResponse';

type Props = {
  letter: Letter;
  onSubmitResponse?: (response: string) => Promise<void>;
};

export default function WarningLetterContent({ letter, onSubmitResponse }: Props) {
  const [showForm, setShowForm] = useState(false);

  if (letter.type !== 'warning') return null;

  const warningData = letter.content;
  if (!warningData) return null;

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">Warning Level</h3>
        <p className="text-gray-700 uppercase font-semibold">{warningData.warning_level} Warning</p>
      </div>

      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">Incident Details</h3>
        <p className="text-gray-600">Date: {new Date(warningData.incident_date).toLocaleDateString()}</p>
        <p className="mt-2 text-gray-700">{warningData.description}</p>
      </div>

      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">Required Improvements</h3>
        <p className="text-gray-700">{warningData.improvement_plan}</p>
      </div>

      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">Consequences</h3>
        <p className="text-gray-700">{warningData.consequences}</p>
      </div>

      {warningData.show_cause_response ? (
        <ShowCauseResponse
          response={warningData.show_cause_response}
          submittedAt={warningData.response_submitted_at}
        />
      ) : onSubmitResponse && !showForm ? (
        <div className="text-center py-6 bg-gray-50 rounded-lg">
          <p className="text-gray-600 mb-4">
            Please provide your response to this warning letter.
          </p>
          <button
            onClick={() => setShowForm(true)}
            className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
          >
            Submit Response
          </button>
        </div>
      ) : showForm && onSubmitResponse ? (
        <ShowCauseForm
          letterId={letter.id}
          onSubmit={async (response) => {
            await onSubmitResponse(response);
            setShowForm(false);
          }}
          onCancel={() => setShowForm(false)}
        />
      ) : null}
    </div>
  );
}