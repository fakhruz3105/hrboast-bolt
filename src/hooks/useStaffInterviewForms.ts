import { useState, useEffect } from 'react';
import { StaffInterviewForm } from '../types/staffInterview';
import * as staffInterviewFormsApi from '../lib/api/staff-interview-forms';

export function useStaffInterviewForms() {
  const [forms, setForms] = useState<StaffInterviewForm[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadForms() {
    try {
      setLoading(true);
      const data = await staffInterviewFormsApi.fetchStaffInterviewForms();
      setForms(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load interview forms'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadForms();
  }, []);

  return {
    forms,
    loading,
    error,
    refresh: loadForms
  };
}