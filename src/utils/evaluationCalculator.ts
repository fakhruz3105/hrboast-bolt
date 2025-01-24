import { Rating } from '../types/evaluation';

export function calculatePercentageScore(ratings: Record<string, Rating>): number {
  const values = Object.values(ratings);
  if (values.length === 0) return 0;

  const totalScore = values.reduce((sum, rating) => sum + rating, 0);
  const maxPossibleScore = values.length * 5; // 5 is the maximum rating
  return (totalScore / maxPossibleScore) * 100;
}

export function getRatingDescription(rating: Rating): string {
  switch (rating) {
    case 1:
      return 'Poor - Significant improvement needed';
    case 2:
      return 'Below Average - Some improvement needed';
    case 3:
      return 'Average - Meets basic expectations';
    case 4:
      return 'Above Average - Exceeds expectations';
    case 5:
      return 'Excellent - Outstanding performance';
    default:
      return '';
  }
}

export function getScoreColor(percentage: number): string {
  if (percentage >= 90) return 'text-green-600';
  if (percentage >= 80) return 'text-blue-600';
  if (percentage >= 70) return 'text-yellow-600';
  return 'text-red-600';
}