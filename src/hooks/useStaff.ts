import { useState, useEffect } from 'react';
import { Staff, StaffFormData } from '../types/staff';
import * as staffApi from '../lib/api/staff';
import { useAuth } from '../contexts/AuthContext';
import { toast } from 'react-hot-toast';

export function useStaff() {
  const { user } = useAuth();
  const [staff, setStaff] = useState<Staff[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadStaff() {
    try {
      setLoading(true);
      const data = await staffApi.fetchStaff();
      setStaff(data);
      setError(null);
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to load staff');
      setError(error);
      toast.error(error.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    if (user?.company_id) {
      loadStaff();
    } else {
      setLoading(false);
    }
  }, [user?.company_id]);

  async function addStaff(staffMember: StaffFormData) {
    try {
      const newStaff = await staffApi.createStaff(staffMember);
      setStaff(prev => [...prev, newStaff]);
      toast.success('Staff member added successfully');
      return newStaff;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to add staff');
      toast.error(error.message);
      throw error;
    }
  }

  async function updateStaff(id: string, updates: Partial<StaffFormData>) {
    try {
      const updatedStaff = await staffApi.updateStaff(id, updates);
      setStaff(prev => prev.map(s => s.id === id ? updatedStaff : s));
      toast.success('Staff member updated successfully');
      return updatedStaff;
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to update staff');
      toast.error(error.message);
      throw error;
    }
  }

  async function deleteStaff(id: string) {
    try {
      await staffApi.deleteStaff(id);
      setStaff(prev => prev.filter(s => s.id !== id));
      toast.success('Staff member deleted successfully');
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Failed to delete staff');
      toast.error(error.message);
      throw error;
    }
  }

  return {
    staff,
    loading,
    error,
    addStaff,
    updateStaff,
    deleteStaff,
    refresh: loadStaff
  };
}