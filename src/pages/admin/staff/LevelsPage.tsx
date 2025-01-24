import React, { useState } from 'react';
import { Plus } from 'lucide-react';
import { StaffLevel } from '../../../types/staffLevel';
import LevelList from '../../../components/admin/staff/LevelList';
import LevelForm from '../../../components/admin/staff/LevelForm';
import { useStaffLevels } from '../../../hooks/useStaffLevels';

export default function LevelsPage() {
  const { levels, loading, error, addLevel, updateLevel, deleteLevel } = useStaffLevels();
  const [showForm, setShowForm] = useState(false);
  const [editingLevel, setEditingLevel] = useState<StaffLevel | null>(null);

  if (loading) {
    return <div className="flex justify-center items-center h-full">Loading levels...</div>;
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-600 p-4 rounded-lg">
        Error: {error.message}
      </div>
    );
  }

  const handleSubmit = async (formData: Omit<StaffLevel, 'id'>) => {
    try {
      if (editingLevel) {
        await updateLevel(editingLevel.id, formData);
      } else {
        await addLevel(formData);
      }
      setShowForm(false);
      setEditingLevel(null);
    } catch (err) {
      console.error('Error saving level:', err);
      alert('Failed to save level. Please check if the name and rank are unique.');
    }
  };

  const handleEdit = (level: StaffLevel) => {
    setEditingLevel(level);
    setShowForm(true);
  };

  const handleDelete = async (id: string) => {
    if (window.confirm('Are you sure you want to delete this level?')) {
      try {
        await deleteLevel(id);
      } catch (err) {
        console.error('Error deleting level:', err);
        alert('Failed to delete level. Please try again.');
      }
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Staff Levels</h1>
        <button
          onClick={() => {
            setEditingLevel(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add New Level
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <h2 className="text-lg font-semibold mb-4">
            {editingLevel ? 'Edit Level' : 'Add New Level'}
          </h2>
          <LevelForm
            initialData={editingLevel}
            existingLevels={levels}
            onSubmit={handleSubmit}
            onCancel={() => {
              setShowForm(false);
              setEditingLevel(null);
            }}
          />
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <LevelList
          levels={levels}
          onEdit={handleEdit}
          onDelete={handleDelete}
        />
      </div>
    </div>
  );
}