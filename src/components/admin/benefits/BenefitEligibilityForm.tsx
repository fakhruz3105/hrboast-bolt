import React, { useState, useEffect } from 'react';
import { StaffLevel } from '../../../types/staffLevel';
import { X, Info } from 'lucide-react';
import { useSupabase } from '../../../providers/SupabaseProvider';

type Props = {
  benefitId: string;
  onClose: () => void;
};

export default function BenefitEligibilityForm({ benefitId, onClose }: Props) {
  const supabase = useSupabase();
  const [levels, setLevels] = useState<StaffLevel[]>([]);
  const [selectedLevels, setSelectedLevels] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    loadData();
  }, [benefitId]);

  const loadData = async () => {
    try {
      // Load staff levels and current eligibility in parallel
      const [levelsResponse, eligibilityResponse] = await Promise.all([
        supabase
          .from('staff_levels')
          .select('*')
          .order('rank'),
        supabase
          .from('benefit_eligibility')
          .select('level_id')
          .eq('benefit_id', benefitId)
      ]);

      if (levelsResponse.error) throw levelsResponse.error;
      if (eligibilityResponse.error) throw eligibilityResponse.error;

      setLevels(levelsResponse.data || []);
      setSelectedLevels(eligibilityResponse.data.map(e => e.level_id));
    } catch (error) {
      console.error('Error loading data:', error);
      alert('Failed to load staff levels');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);

    try {
      // First delete existing eligibility
      const { error: deleteError } = await supabase
        .from('benefit_eligibility')
        .delete()
        .eq('benefit_id', benefitId);

      if (deleteError) throw deleteError;

      // Then insert new eligibility if any levels are selected
      if (selectedLevels.length > 0) {
        const { error: insertError } = await supabase
          .from('benefit_eligibility')
          .insert(
            selectedLevels.map(levelId => ({
              benefit_id: benefitId,
              level_id: levelId
            }))
          );

        if (insertError) throw insertError;
      }

      onClose();
    } catch (error) {
      console.error('Error saving eligibility:', error);
      alert('Failed to save eligibility settings');
    } finally {
      setSaving(false);
    }
  };

  const toggleAll = () => {
    if (selectedLevels.length === levels.length) {
      setSelectedLevels([]);
    } else {
      setSelectedLevels(levels.map(level => level.id));
    }
  };

  if (loading) {
    return (
      <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
        <div className="bg-white rounded-lg p-6">
          <div className="animate-pulse">Loading...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
      <div className="bg-white rounded-lg shadow-lg p-6 max-w-md w-full mx-4">
        <div className="flex justify-between items-start mb-6">
          <div>
            <h2 className="text-xl font-bold text-gray-900">Position Eligibility</h2>
            <p className="mt-1 text-sm text-gray-500">Select which positions can access this benefit</p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-500"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="bg-blue-50 border border-blue-200 rounded-md p-4 mb-6">
          <div className="flex">
            <Info className="h-5 w-5 text-blue-400 mr-2" />
            <div className="text-sm text-blue-700">
              Staff members will only be able to claim this benefit if their position is selected below.
            </div>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <button
              type="button"
              onClick={toggleAll}
              className="text-sm text-indigo-600 hover:text-indigo-800"
            >
              {selectedLevels.length === levels.length ? 'Deselect All' : 'Select All'}
            </button>
          </div>

          <div className="space-y-3 max-h-60 overflow-y-auto">
            {levels.map((level) => (
              <label
                key={level.id}
                className="flex items-center p-3 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <input
                  type="checkbox"
                  className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                  checked={selectedLevels.includes(level.id)}
                  onChange={(e) => {
                    if (e.target.checked) {
                      setSelectedLevels([...selectedLevels, level.id]);
                    } else {
                      setSelectedLevels(selectedLevels.filter(id => id !== level.id));
                    }
                  }}
                />
                <div className="ml-3">
                  <div className="font-medium text-gray-900">{level.name}</div>
                  <div className="text-sm text-gray-500">{level.description}</div>
                </div>
              </label>
            ))}
          </div>

          <div className="mt-6 flex justify-end space-x-3 border-t pt-4">
            <button
              type="button"
              onClick={onClose}
              className="px-4 py-2 text-gray-700 hover:bg-gray-50 rounded-md"
              disabled={saving}
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 disabled:opacity-50"
              disabled={saving}
            >
              {saving ? 'Saving...' : 'Save Changes'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}