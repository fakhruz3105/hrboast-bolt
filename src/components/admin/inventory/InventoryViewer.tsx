import React from 'react';
import { X } from 'lucide-react';
import { InventoryItem } from '../../../types/inventory';

type Props = {
  item: InventoryItem;
  onClose: () => void;
};

const ITEM_TYPE_LABELS: Record<string, string> = {
  laptop: 'Laptop',
  phone: 'Phone',
  tablet: 'Tablet',
  monitor: 'Monitor',
  other: 'Other'
};

const CONDITION_COLORS: Record<string, string> = {
  new: 'bg-green-100 text-green-800',
  good: 'bg-blue-100 text-blue-800',
  fair: 'bg-yellow-100 text-yellow-800',
  poor: 'bg-red-100 text-red-800'
};

export default function InventoryViewer({ item, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black/50 z-[70] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{item.item_name}</h2>
                {item.staff && (
                  <p className="text-gray-600 mt-1">
                    Assigned to: {item.staff.name} - {item.staff.departments?.[0]?.department?.name}
                  </p>
                )}
              </div>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700"
              >
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {item.image_url && (
                <div className="col-span-full">
                  <img 
                    src={item.image_url} 
                    alt={item.item_name}
                    className="w-full max-h-96 object-contain rounded-lg"
                  />
                </div>
              )}

              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Item Details</h3>
                <dl className="grid grid-cols-1 gap-4">
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Type</dt>
                    <dd className="mt-1 text-sm text-gray-900">{ITEM_TYPE_LABELS[item.item_type]}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Brand</dt>
                    <dd className="mt-1 text-sm text-gray-900">{item.brand}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Model</dt>
                    <dd className="mt-1 text-sm text-gray-900">{item.model}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Serial Number</dt>
                    <dd className="mt-1 text-sm text-gray-900">{item.serial_number}</dd>
                  </div>
                </dl>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900 mb-4">Status Information</h3>
                <dl className="grid grid-cols-1 gap-4">
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Condition</dt>
                    <dd className="mt-1">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${CONDITION_COLORS[item.condition]}`}>
                        {item.condition.charAt(0).toUpperCase() + item.condition.slice(1)}
                      </span>
                    </dd>
                  </div>
                  {item.purchase_date && (
                    <div>
                      <dt className="text-sm font-medium text-gray-500">Purchase Date</dt>
                      <dd className="mt-1 text-sm text-gray-900">
                        {new Date(item.purchase_date).toLocaleDateString()}
                      </dd>
                    </div>
                  )}
                  {item.notes && (
                    <div>
                      <dt className="text-sm font-medium text-gray-500">Notes</dt>
                      <dd className="mt-1 text-sm text-gray-900 whitespace-pre-wrap">{item.notes}</dd>
                    </div>
                  )}
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Last Updated</dt>
                    <dd className="mt-1 text-sm text-gray-900">
                      {new Date(item.updated_at).toLocaleDateString()}
                    </dd>
                  </div>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}