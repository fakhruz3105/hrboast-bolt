import React from 'react';
import { StaffLevel } from '../../../types/staffLevel';
import { Edit, Trash2 } from 'lucide-react';

type Props = {
  levels: StaffLevel[];
  onEdit: (level: StaffLevel) => void;
  onDelete: (id: number) => void;
};

export default function LevelList({ levels, onEdit, onDelete }: Props) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rank</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Level</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {levels.map((level) => (
            <tr key={level.id}>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{level.rank}</td>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{level.name}</td>
              <td className="px-6 py-4 text-sm text-gray-500">{level.description}</td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button
                  onClick={() => onEdit(level)}
                  className="text-indigo-600 hover:text-indigo-900 mr-3"
                >
                  <Edit className="h-4 w-4" />
                </button>
                <button
                  onClick={() => onDelete(level.id)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}