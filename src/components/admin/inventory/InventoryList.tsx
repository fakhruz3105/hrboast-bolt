import React from 'react';
import { Eye, Edit, Trash2 } from 'lucide-react';
import { InventoryItem } from '../../../types/inventory';

type Props = {
  items: InventoryItem[];
  onView: (item: InventoryItem) => void;
  onEdit?: (item: InventoryItem) => void;
  onDelete?: (id: string) => void;
  isStaffView?: boolean;
};

const ITEM_TYPE_LABELS: Record<string, string> = {
  'Laptop': 'Laptop',
  'Phone': 'Phone',
  'Tablet': 'Tablet',
  'Others': 'Others'
};

const CONDITION_COLORS: Record<string, string> = {
  'New': 'bg-green-100 text-green-800',
  'Used': 'bg-blue-100 text-blue-800',
  'Refurbished': 'bg-yellow-100 text-yellow-800'
};

export default function InventoryList({ items, onView, onEdit, onDelete, isStaffView }: Props) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Item</th>
            {!isStaffView && (
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
            )}
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Brand/Model</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Serial Number</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Condition</th>
            <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {items.map((item) => (
            <tr key={item.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">{item.item_name}</div>
              </td>
              {!isStaffView && (
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">{item.staff?.name}</div>
                  <div className="text-xs text-gray-500">
                    {item.staff?.departments?.[0]?.department?.name}
                  </div>
                </td>
              )}
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="text-sm text-gray-900">
                  {ITEM_TYPE_LABELS[item.item_type] || item.item_type}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm text-gray-900">{item.brand}</div>
                <div className="text-xs text-gray-500">{item.model}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {item.serial_number}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${CONDITION_COLORS[item.condition]}`}>
                  {item.condition}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <div className="flex justify-end space-x-2">
                  <button
                    onClick={() => onView(item)}
                    className="text-indigo-600 hover:text-indigo-900"
                    title="View Details"
                  >
                    <Eye className="h-4 w-4" />
                  </button>
                  {(isStaffView || onEdit) && (
                    <button
                      onClick={() => onEdit?.(item)}
                      className="text-blue-600 hover:text-blue-900"
                      title="Edit Item"
                    >
                      <Edit className="h-4 w-4" />
                    </button>
                  )}
                  {(isStaffView || onDelete) && (
                    <button
                      onClick={() => onDelete?.(item.id)}
                      className="text-red-600 hover:text-red-900"
                      title="Delete Item"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  )}
                </div>
              </td>
            </tr>
          ))}
          {items.length === 0 && (
            <tr>
              <td colSpan={isStaffView ? 6 : 7} className="px-6 py-4 text-center text-sm text-gray-500">
                No inventory items found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}