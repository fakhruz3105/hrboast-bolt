import React, { useState } from 'react';
import { Staff } from '../../../types/staff';
import { InventoryFormData } from '../../../types/inventory';

type Props = {
  staff?: Staff[];
  initialData?: any;
  onSubmit: (data: InventoryFormData, staffId: string, imageFile?: File) => Promise<void>;
  onCancel: () => void;
  isStaffView?: boolean;
};

const ITEM_TYPES = [
  { value: 'Laptop', label: 'Laptop' },
  { value: 'Phone', label: 'Phone' },
  { value: 'Tablet', label: 'Tablet' },
  { value: 'Others', label: 'Others' }
];

const CONDITIONS = [
  { value: 'New', label: 'New' },
  { value: 'Used', label: 'Used' },
  { value: 'Refurbished', label: 'Refurbished' }
];

export default function InventoryForm({ staff, initialData, onSubmit, onCancel, isStaffView }: Props) {
  const [formData, setFormData] = useState<InventoryFormData>({
    item_type: initialData?.item_type || 'Laptop',
    item_name: initialData?.item_name || '',
    brand: initialData?.brand || '',
    model: initialData?.model || '',
    serial_number: initialData?.serial_number || '',
    purchase_date: initialData?.purchase_date || '',
    condition: initialData?.condition || 'New',
    price: initialData?.price || 0,
    notes: initialData?.notes || ''
  });

  const [selectedStaffId, setSelectedStaffId] = useState(initialData?.staff_id || '');
  const [imageFile, setImageFile] = useState<File>();
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit(formData, selectedStaffId, imageFile);
    } finally {
      setLoading(false);
    }
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      if (file.size > 5 * 1024 * 1024) { // 5MB limit
        alert('Image size must be less than 5MB');
        return;
      }
      setImageFile(file);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {!isStaffView && staff && (
        <div>
          <label className="block text-sm font-medium text-gray-700">Staff Member</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={selectedStaffId}
            onChange={(e) => setSelectedStaffId(e.target.value)}
            disabled={loading}
          >
            <option value="">Select Staff Member</option>
            {staff.map((member) => (
              <option key={member.id} value={member.id}>
                {member.name} - {member.departments?.[0]?.department?.name}
              </option>
            ))}
          </select>
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700">Item Type</label>
        <select
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.item_type}
          onChange={(e) => setFormData({ ...formData, item_type: e.target.value as any })}
          disabled={loading}
        >
          {ITEM_TYPES.map((type) => (
            <option key={type.value} value={type.value}>{type.label}</option>
          ))}
        </select>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Item Name</label>
        <input
          type="text"
          required
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.item_name}
          onChange={(e) => setFormData({ ...formData, item_name: e.target.value })}
          disabled={loading}
          placeholder="e.g., MacBook Pro, iPhone 13"
        />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Brand</label>
          <input
            type="text"
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.brand}
            onChange={(e) => setFormData({ ...formData, brand: e.target.value })}
            disabled={loading}
            placeholder="e.g., Apple, Dell"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Model</label>
          <input
            type="text"
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.model}
            onChange={(e) => setFormData({ ...formData, model: e.target.value })}
            disabled={loading}
            placeholder="e.g., M2, XPS 13"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Serial Number</label>
          <input
            type="text"
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.serial_number}
            onChange={(e) => setFormData({ ...formData, serial_number: e.target.value })}
            disabled={loading}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Price (RM)</label>
          <input
            type="number"
            required
            min="0"
            step="0.01"
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.price}
            onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
            disabled={loading}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Purchase Date</label>
          <input
            type="date"
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.purchase_date}
            onChange={(e) => setFormData({ ...formData, purchase_date: e.target.value })}
            disabled={loading}
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Condition</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.condition}
            onChange={(e) => setFormData({ ...formData, condition: e.target.value as any })}
            disabled={loading}
          >
            {CONDITIONS.map((condition) => (
              <option key={condition.value} value={condition.value}>{condition.label}</option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Notes</label>
        <textarea
          rows={3}
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={formData.notes}
          onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
          disabled={loading}
          placeholder="Additional details or comments about the item..."
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Item Image</label>
        <input
          type="file"
          accept="image/*"
          className="mt-1 block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-indigo-50 file:text-indigo-700 hover:file:bg-indigo-100"
          onChange={handleImageChange}
          disabled={loading}
        />
        <p className="mt-1 text-sm text-gray-500">Max file size: 5MB. Supported formats: JPG, PNG</p>
      </div>

      <div className="flex justify-end space-x-3">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
          disabled={loading}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
          disabled={loading || (!isStaffView && !selectedStaffId)}
        >
          {loading ? 'Saving...' : (initialData ? 'Update Item' : 'Add Item')}
        </button>
      </div>
    </form>
  );
}