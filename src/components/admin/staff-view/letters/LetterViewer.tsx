import React, { useState } from 'react';
import { X } from 'lucide-react';
import { Letter } from '../../../../types/letter';
import ExitInterviewForm from './ExitInterviewForm';
import LetterContent from './LetterContent';

type Props = {
  letter: Letter;
  onClose: () => void;
  onSubmit?: () => void;
};

export default function LetterViewer({ letter, onClose, onSubmit }: Props) {
  const [showExitForm, setShowExitForm] = useState(false);

  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{letter.title}</h2>
                <p className="text-sm text-gray-600 mt-1">
                  Issued on {new Date(letter.issued_date).toLocaleDateString()}
                </p>
              </div>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            {letter.type === 'interview' && letter.content?.type === 'exit' && letter.status === 'pending' ? (
              showExitForm ? (
                <ExitInterviewForm
                  letterId={letter.id}
                  staffId={letter.staff_id} // Pass the staff_id
                  onSubmit={() => {
                    if (onSubmit) onSubmit();
                    onClose();
                  }}
                  onCancel={() => setShowExitForm(false)}
                />
              ) : (
                <div className="text-center py-6">
                  <p className="text-gray-600 mb-4">
                    Please complete your exit interview form.
                  </p>
                  <button
                    onClick={() => setShowExitForm(true)}
                    className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                  >
                    Start Exit Interview
                  </button>
                </div>
              )
            ) : (
              <LetterContent letter={letter} onSubmitResponse={onSubmit} />
            )}
          </div>
        </div>
      </div>
    </div>
  );
}