import { useState, useEffect } from 'react';
import { Department, DepartmentFormData } from '../types/department';
import * as departmentsApi from '../lib/api/departments';

export function useDepartments() {
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  async function loadDepartments() {
    try {
      setLoading(true);
      const data = await departmentsApi.fetchDepartments();
      setDepartments(data);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Failed to load departments'));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadDepartments();
  }, []);

  async function addDepartment(department: DepartmentFormData) {
    try {
      const newDepartment = await departmentsApi.createDepartment(department);
      setDepartments(prev => [...prev, newDepartment]);
      return newDepartment;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to add department');
    }
  }

  async function updateDepartment(id: string, updates: Partial<DepartmentFormData>) {
    try {
      const updatedDepartment = await departmentsApi.updateDepartment(id, updates);
      setDepartments(prev => prev.map(dept => dept.id === id ? updatedDepartment : dept));
      return updatedDepartment;
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to update department');
    }
  }

  async function deleteDepartment(id: string) {
    try {
      await departmentsApi.deleteDepartment(id);
      setDepartments(prev => prev.filter(dept => dept.id !== id));
    } catch (err) {
      throw err instanceof Error ? err : new Error('Failed to delete department');
    }
  }

  return {
    departments,
    loading,
    error,
    addDepartment,
    updateDepartment,
    deleteDepartment,
    refresh: loadDepartments
  };
}