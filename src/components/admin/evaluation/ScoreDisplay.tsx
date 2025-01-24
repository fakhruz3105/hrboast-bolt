import React from 'react';

type Props = {
  percentage: number | null | undefined;
  size?: 'sm' | 'lg';
};

export default function ScoreDisplay({ percentage, size = 'sm' }: Props) {
  if (percentage === null || percentage === undefined) {
    return (
      <div className="text-center">
        <div className="text-gray-500 text-sm">
          No score
        </div>
      </div>
    );
  }

  const getScoreColor = (score: number): string => {
    if (score >= 90) return 'text-green-600';
    if (score >= 80) return 'text-blue-600';
    if (score >= 70) return 'text-yellow-600';
    return 'text-red-600';
  };

  const sizeClasses = size === 'lg' 
    ? 'text-4xl font-bold'
    : 'text-xl font-semibold';

  return (
    <div className="text-center">
      <div className={`${sizeClasses} ${getScoreColor(percentage)}`}>
        {percentage.toFixed(1)}%
      </div>
      <div className="text-sm text-gray-500">
        Overall Score
      </div>
    </div>
  );
}