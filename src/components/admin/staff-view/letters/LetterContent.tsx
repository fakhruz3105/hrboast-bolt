import React from 'react';
import { Letter } from '../../../../types/letter';
import ExitInterviewContent from './content/ExitInterviewContent';
import WarningLetterContent from './content/WarningLetterContent';
import ShowCauseContent from './content/ShowCauseContent';

type Props = {
  letter: Letter;
  onSubmitResponse?: () => void;
};

export default function LetterContent({ letter, onSubmitResponse }: Props) {
  if (!letter) return null;

  switch (letter.type) {
    case 'warning':
      return <WarningLetterContent letter={letter} onSubmitResponse={onSubmitResponse} />;
    case 'interview':
      return <ExitInterviewContent letter={letter} />;
    case 'show_cause':
      return <ShowCauseContent letter={letter} onSubmitResponse={onSubmitResponse} />;
    default:
      return (
        <div className="text-center py-6">
          <p className="text-gray-600">Content not available</p>
        </div>
      );
  }
}