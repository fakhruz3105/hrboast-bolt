export type LetterType = 'warning' | 'evaluation' | 'interview' | 'notice' | 'show_cause';
export type LetterStatus = 'draft' | 'pending' | 'submitted' | 'completed' | 'signed';

export type Letter = {
  id: string;
  title: string;
  type: LetterType;
  content: any;
  issued_date: string;
  document_url?: string;
  status: LetterStatus;
};