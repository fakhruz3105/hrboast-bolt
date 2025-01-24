import React from 'react';
import { X } from 'lucide-react';
import ScoreDisplay from '../ScoreDisplay';

type Props = {
  title: string;
  type: string;
  staff?: { name: string; department?: { name: string } };
  manager?: { name: string };
  status: string;
  score?: number;
  onClose: () => void;
};

export default function ResponseHeader({ title, type, staff, manager, status, score, onClose }: Props) {
  return (
    <div className="px-6 py-4 border-b border-gray-200">
      <div className="flex justify-between items-start">
        <div>
          <div className="flex items-center gap-4">
            <h2 className="text-2xl font-bold text-gray-900">{title}</h2>
            <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
              status === 'completed'
                ? 'bg-green-100 text-green-800'
                : 'bg-yellow-100 text-yellow-800'
            }`}>
              {status}
            </span>
          </div>
          
          <div className="mt-2 space-y-1 text-sm text-gray-600">
            <p>Type: <span className="capitalize">{type}</span></p>
            {staff && (
              <p>Staff: {staff.name} {staff.department && `(${staff.department.name})`}</p>
            )}
            {manager && <p>Manager: {manager.name}</p>}
          </div>
        </div>

        <div className="flex items-start gap-6">
          {score !== undefined && (
            <div className="text-center">
              <ScoreDisplay percentage={score} size="lg" />
            </div>
          )}
          <button 
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 transition-colors"
          >
            <X className="h-6 w-6" />
          </button>
        </div>
      </div>
    </div>
  );
}