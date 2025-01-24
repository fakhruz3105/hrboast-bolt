export type EvaluationType = 'quarter' | 'half-year' | 'yearly';
export type EvaluationStatus = 'pending' | 'completed';
export type Rating = 1 | 2 | 3 | 4 | 5;

export type QuestionType = 'rating' | 'checkbox' | 'text';

export type EvaluationQuestion = {
  id: string;
  category: string;
  question: string;
  description?: string;
  type: QuestionType;
  options?: string[];
};

export type EvaluationForm = {
  id: string;
  title: string;
  type: EvaluationType;
  questions: EvaluationQuestion[];
  created_at?: string;
  updated_at?: string;
};

export type EvaluationResponse = {
  id: string;
  evaluation_id: string;
  staff_id: string;
  manager_id: string;
  self_ratings: Record<string, Rating>;
  self_comments: Record<string, string>;
  manager_ratings: Record<string, Rating>;
  manager_comments: Record<string, string>;
  percentage_score: number;
  status: EvaluationStatus;
  submitted_at?: string;
  completed_at?: string;
  staff?: {
    name: string;
    department?: {
      name: string;
    };
  };
  manager?: {
    name: string;
  };
  evaluation?: EvaluationForm;
};