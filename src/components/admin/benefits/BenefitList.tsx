import React from 'react';
import { Edit, Trash2, Users } from 'lucide-react';

type Props = {
  benefits: any[];
  onEdit: (benefit: any) => void;
  onDelete: (id: string) => void;
  onManageEligibility: (benefit: any) => void;
};

export default function BenefitList({ benefits, onEdit, onDelete, onManageEligibility }: Props) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Amount</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Frequency</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {benefits.map((benefit) => (
            <tr key={benefit.id}>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">{benefit.name}</div>
              </td>
              <td className="px-6 py-4">
                <div className="text-sm text-gray-500">{benefit.description}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm text-gray-900">RM {benefit.amount.toFixed(2)}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm text-gray-500">{benefit.frequency}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                <button
                  onClick={() => onManageEligibility(benefit)}
                  className="text-indigo-600 hover:text-indigo-900"
                  title="Manage Eligibility"
                >
                  <Users className="h-4 w-4" />
                </button>
                <button
                  onClick={() => onEdit(benefit)}
                  className="text-blue-600 hover:text-blue-900"
                  title="Edit Benefit"
                >
                  <Edit className="h-4 w-4" />
                </button>
                <button
                  onClick={() => onDelete(benefit.id)}
                  className="text-red-600 hover:text-red-900"
                  title="Delete Benefit"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </td>
            </tr>
          ))}
          {benefits.length === 0 && (
            <tr>
              <td colSpan={5} className="px-6 py-4 text-center text-sm text-gray-500">
                No benefits found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}