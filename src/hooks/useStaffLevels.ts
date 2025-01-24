import { useState, useEffect } from 'react';
import { StaffLevel, StaffLevelFormData } from '../types/staffLevel';
import * as staffLevelsApi from '../lib/api/staff-levels';

export function useStaffLevels() {
  const [levels, setLevels] = useState<StaffLevel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadLevels() {
    try {
      setLoading(true);
      const data = await staffLevelsApi.fetchStaffLevels();
      setLevels(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load staff levels'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadLevels();
  }, []);

  async function addLevel(level: StaffLevelFormData) {
    try {
      const newLevel = await staffLevelsApi.createStaffLevel(level);
      setLevels(prev => [...prev, newLevel]);
      return newLevel;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to add staff level');
    }
  }

  async function updateLevel(id: string, updates: Partial<StaffLevelFormData>) {
    try {
      const updatedLevel = await staffLevelsApi.updateStaffLevel(id, updates);
      setLevels(prev => prev.map(level => level.id === id ? updatedLevel : level));
      return updatedLevel;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to update staff level');
    }
  }

  async function deleteLevel(id: string) {
    try {
      await staffLevelsApi.deleteStaffLevel(id);
      setLevels(prev => prev.filter(level => level.id !== id));
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to delete staff level');
    }
  }

  return {
    levels,
    loading,
    error,
    addLevel,
    updateLevel,
    deleteLevel,
    refresh: loadLevels
  };
}