import React from 'react';
import { X } from 'lucide-react';

type Props = {
  title: string;
  type: string;
  createdAt: string;
  onClose: () => void;
};

export default function EvaluationHeader({ title, type, createdAt, onClose }: Props) {
  return (
    <div className="px-6 py-4 border-b border-gray-200">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">{title}</h2>
          <div className="mt-1 flex items-center text-sm text-gray-600 space-x-4">
            <span className="capitalize">{type}</span>
            <span>•</span>
            <span>Created {new Date(createdAt).toLocaleDateString()}</span>
          </div>
        </div>
        <button 
          onClick={onClose}
          className="text-gray-500 hover:text-gray-700 transition-colors"
        >
          <X className="h-6 w-6" />
        </button>
      </div>
    </div>
  );
}