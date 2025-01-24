import React from 'react';
import { Rating } from '../../../types/evaluation';
import { getRatingDescription } from '../../../utils/evaluationCalculator';

type Props = {
  value: Rating | null;
  onChange: (rating: Rating) => void;
  required?: boolean;
};

export default function RatingInput({ value, onChange, required = false }: Props) {
  return (
    <div className="space-y-2">
      <div className="flex items-center space-x-4">
        {[1, 2, 3, 4, 5].map((rating) => (
          <label key={rating} className="flex items-center">
            <input
              type="radio"
              required={required}
              checked={value === rating}
              onChange={() => onChange(rating as Rating)}
              className="sr-only peer"
            />
            <div className={`
              w-8 h-8 flex items-center justify-center rounded-full
              border-2 cursor-pointer transition-colors
              ${value === rating 
                ? 'bg-indigo-600 text-white border-indigo-600' 
                : 'bg-white text-gray-700 border-gray-300 hover:border-indigo-500'
              }
              peer-focus:ring-2 peer-focus:ring-indigo-500 peer-focus:ring-offset-2
            `}>
              {rating}
            </div>
          </label>
        ))}
      </div>
      {value && (
        <p className="text-sm text-gray-600">
          {getRatingDescription(value)}
        </p>
      )}
    </div>
  );
}