import { useState, useEffect } from 'react';
import { StaffLevel } from '../types/supabase';
import * as staffLevelsApi from '../lib/api/staff-levels';

export function useStaffLevel(id: string) {
  const [level, setLevel] = useState<StaffLevel | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    async function loadLevel() {
      try {
        setLoading(true);
        const data = await staffLevelsApi.getStaffLevel(id);
        setLevel(data);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Failed to load staff level'));
      } finally {
        setLoading(false);
      }
    }

    loadLevel();
  }, [id]);

  return { level, loading, error };
}