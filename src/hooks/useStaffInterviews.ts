import { useState, useEffect } from 'react';
import { StaffInterview, StaffInterviewFormData } from '../types/staffInterview';
import * as staffInterviewsApi from '../lib/api/staff-interviews';

export function useStaffInterviews() {
  const [interviews, setInterviews] = useState<StaffInterview[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadInterviews() {
    try {
      setLoading(true);
      const data = await staffInterviewsApi.fetchStaffInterviews();
      setInterviews(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load interviews'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadInterviews();
  }, []);

  async function createInterview(interview: StaffInterviewFormData) {
    try {
      const newInterview = await staffInterviewsApi.createStaffInterview(interview);
      setInterviews(prev => [newInterview, ...prev]);
      return newInterview;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to create interview');
    }
  }

  async function updateInterview(id: string, updates: Partial<StaffInterviewFormData>) {
    try {
      const updatedInterview = await staffInterviewsApi.updateStaffInterview(id, updates);
      setInterviews(prev => prev.map(interview => 
        interview.id === id ? updatedInterview : interview
      ));
      return updatedInterview;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to update interview');
    }
  }

  async function deleteInterview(id: string) {
    try {
      await staffInterviewsApi.deleteStaffInterview(id);
      setInterviews(prev => prev.filter(interview => interview.id !== id));
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to delete interview');
    }
  }

  return {
    interviews,
    loading,
    error,
    createInterview,
    updateInterview,
    deleteInterview,
    refresh: loadInterviews
  };
}