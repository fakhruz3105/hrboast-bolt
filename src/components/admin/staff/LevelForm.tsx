import React, { useState, useEffect } from 'react';
import { StaffLevel, StaffLevelFormData } from '../../../types/staffLevel';

type Props = {
  initialData?: StaffLevel | null;
  existingLevels: StaffLevel[];
  onSubmit: (data: StaffLevelFormData) => void;
  onCancel: () => void;
};

export default function LevelForm({ initialData, existingLevels, onSubmit, onCancel }: Props) {
  const [formData, setFormData] = useState<StaffLevelFormData>({
    name: initialData?.name || '',
    description: initialData?.description || '',
    rank: initialData?.rank || getNextAvailableRank(),
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  function getNextAvailableRank(): number {
    if (!existingLevels.length) return 1;
    const ranks = existingLevels.map(level => level.rank);
    const maxRank = Math.max(...ranks);
    return maxRank + 1;
  }

  function validateForm(): boolean {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    } else if (
      existingLevels.some(
        level => 
          level.name.toLowerCase() === formData.name.toLowerCase() && 
          level.id !== initialData?.id
      )
    ) {
      newErrors.name = 'This name already exists';
    }

    if (!formData.description.trim()) {
      newErrors.description = 'Description is required';
    }

    if (!formData.rank || formData.rank < 1) {
      newErrors.rank = 'Rank must be a positive number';
    } else if (
      existingLevels.some(
        level => 
          level.rank === formData.rank && 
          level.id !== initialData?.id
      )
    ) {
      newErrors.rank = 'This rank is already taken';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      onSubmit(formData);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label className="block text-sm font-medium text-gray-700">Level Name</label>
        <input
          type="text"
          required
          className={`mt-1 block w-full rounded-md border px-3 py-2 ${
            errors.name ? 'border-red-500' : 'border-gray-300'
          }`}
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />
        {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700">Description</label>
        <textarea
          required
          className={`mt-1 block w-full rounded-md border px-3 py-2 ${
            errors.description ? 'border-red-500' : 'border-gray-300'
          }`}
          value={formData.description}
          onChange={(e) => setFormData({ ...formData, description: e.target.value })}
        />
        {errors.description && <p className="mt-1 text-sm text-red-500">{errors.description}</p>}
      </div>
      
      <div>
        <label className="block text-sm font-medium text-gray-700">Rank</label>
        <input
          type="number"
          required
          min="1"
          className={`mt-1 block w-full rounded-md border px-3 py-2 ${
            errors.rank ? 'border-red-500' : 'border-gray-300'
          }`}
          value={formData.rank}
          onChange={(e) => setFormData({ ...formData, rank: parseInt(e.target.value) || 1 })}
        />
        {errors.rank && <p className="mt-1 text-sm text-red-500">{errors.rank}</p>}
      </div>

      <div className="flex justify-end space-x-3 mt-6">
        <button
          type="button"
          onClick={onCancel}
          className="px-4 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50"
        >
          Cancel
        </button>
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          {initialData ? 'Update Level' : 'Create Level'}
        </button>
      </div>
    </form>
  );
}