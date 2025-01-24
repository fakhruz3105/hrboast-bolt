import React, { useState, useEffect } from 'react';
import { StaffFormData } from '../../../types/staff';
import { Department } from '../../../types/department';
import { StaffLevel } from '../../../types/staffLevel';
import { toast } from 'react-hot-toast';

type Props = {
  initialData?: any | null;
  departments: Department[];
  levels: StaffLevel[];
  onSubmit: (data: StaffFormData) => void;
  onCancel: () => void;
};

export default function StaffForm({ initialData, departments, levels, onSubmit, onCancel }: Props) {
  const [formData, setFormData] = useState<StaffFormData>({
    name: '',
    phone_number: '',
    email: '',
    department_ids: [],
    primary_department_id: '',
    level_ids: [],
    primary_level_id: '',
    join_date: new Date().toISOString().split('T')[0],
    status: 'probation'
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  // Initialize form data when editing
  useEffect(() => {
    if (initialData) {
      // Transform departments data
      const departmentIds = initialData.departments?.map((d: any) => d.department_id) || [];
      const primaryDepartment = initialData.departments?.find((d: any) => d.is_primary);

      // Transform levels data
      const levelIds = initialData.levels?.map((l: any) => l.level_id) || [];
      const primaryLevel = initialData.levels?.find((l: any) => l.is_primary);

      setFormData({
        name: initialData.name || '',
        phone_number: initialData.phone_number || '',
        email: initialData.email || '',
        department_ids: departmentIds,
        primary_department_id: primaryDepartment?.department_id || '',
        level_ids: levelIds,
        primary_level_id: primaryLevel?.level_id || '',
        join_date: initialData.join_date || new Date().toISOString().split('T')[0],
        status: initialData.status || 'probation'
      });
    }
  }, [initialData]);

  const validateForm = () => {
    const newErrors: Record<string, string> = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    if (!formData.phone_number.trim()) {
      newErrors.phone_number = 'Phone number is required';
    } else if (!/^\+?[\d\s-]+$/.test(formData.phone_number)) {
      newErrors.phone_number = 'Invalid phone number format';
    }

    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = 'Invalid email format';
    }

    if (formData.department_ids.length === 0) {
      newErrors.department_ids = 'At least one department is required';
    }

    if (!formData.primary_department_id) {
      newErrors.primary_department_id = 'Primary department is required';
    }

    if (formData.level_ids.length === 0) {
      newErrors.level_ids = 'At least one level is required';
    }

    if (!formData.primary_level_id) {
      newErrors.primary_level_id = 'Primary level is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (validateForm()) {
      try {
        onSubmit(formData);
      } catch (error) {
        console.error('Error submitting form:', error);
        toast.error('Failed to save staff member');
      }
    }
  };

  const handleDepartmentChange = (deptId: string) => {
    const newDepartmentIds = formData.department_ids.includes(deptId)
      ? formData.department_ids.filter(id => id !== deptId)
      : [...formData.department_ids, deptId];

    // If removing the primary department, reset it
    const newPrimaryDepartmentId = formData.primary_department_id === deptId && !newDepartmentIds.includes(deptId)
      ? ''
      : formData.primary_department_id;

    setFormData({
      ...formData,
      department_ids: newDepartmentIds,
      primary_department_id: newPrimaryDepartmentId
    });
  };

  const handleLevelChange = (levelId: string) => {
    const newLevelIds = formData.level_ids.includes(levelId)
      ? formData.level_ids.filter(id => id !== levelId)
      : [...formData.level_ids, levelId];

    // If removing the primary level, reset it
    const newPrimaryLevelId = formData.primary_level_id === levelId && !newLevelIds.includes(levelId)
      ? ''
      : formData.primary_level_id;

    setFormData({
      ...formData,
      level_ids: newLevelIds,
      primary_level_id: newPrimaryLevelId
    });
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <label className="block text-sm font-medium text-gray-700">Name</label>
        <input
          type="text"
          required
          className={`mt-1 block w-full rounded-md border ${
            errors.name ? 'border-red-500' : 'border-gray-300'
          } px-3 py-2`}
          value={formData.name}
          onChange={(e) => setFormData({ ...formData, name: e.target.value })}
        />
        {errors.name && <p className="mt-1 text-sm text-red-500">{errors.name}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Phone Number</label>
        <input
          type="tel"
          required
          className={`mt-1 block w-full rounded-md border ${
            errors.phone_number ? 'border-red-500' : 'border-gray-300'
          } px-3 py-2`}
          value={formData.phone_number}
          onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
        />
        {errors.phone_number && <p className="mt-1 text-sm text-red-500">{errors.phone_number}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Email</label>
        <input
          type="email"
          required
          className={`mt-1 block w-full rounded-md border ${
            errors.email ? 'border-red-500' : 'border-gray-300'
          } px-3 py-2`}
          value={formData.email}
          onChange={(e) => setFormData({ ...formData, email: e.target.value })}
        />
        {errors.email && <p className="mt-1 text-sm text-red-500">{errors.email}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Departments</label>
        <div className="space-y-2">
          {departments.map((dept) => (
            <label key={dept.id} className="flex items-center">
              <input
                type="checkbox"
                className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                checked={formData.department_ids.includes(dept.id)}
                onChange={() => handleDepartmentChange(dept.id)}
              />
              <span className="ml-2 text-sm text-gray-900">{dept.name}</span>
            </label>
          ))}
        </div>
        {errors.department_ids && <p className="mt-1 text-sm text-red-500">{errors.department_ids}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Primary Department</label>
        <select
          required
          className={`mt-1 block w-full rounded-md border ${
            errors.primary_department_id ? 'border-red-500' : 'border-gray-300'
          } px-3 py-2`}
          value={formData.primary_department_id}
          onChange={(e) => setFormData({ ...formData, primary_department_id: e.target.value })}
        >
          <option value="">Select Primary Department</option>
          {departments
            .filter(dept => formData.department_ids.includes(dept.id))
            .map((dept) => (
              <option key={dept.id} value={dept.id}>{dept.name}</option>
            ))}
        </select>
        {errors.primary_department_id && <p className="mt-1 text-sm text-red-500">{errors.primary_department_id}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">Staff Levels</label>
        <div className="space-y-2">
          {levels.map((level) => (
            <label key={level.id} className="flex items-center">
              <input
                type="checkbox"
                className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                checked={formData.level_ids.includes(level.id)}
                onChange={() => handleLevelChange(level.id)}
              />
              <span className="ml-2 text-sm text-gray-900">{level.name}</span>
            </label>
          ))}
        </div>
        {errors.level_ids && <p className="mt-1 text-sm text-red-500">{errors.level_ids}</p>}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Primary Level</label>
        <select
          required
          className={`mt-1 block w-full rounded-md border ${
            errors.primary_level_id ? 'border-red-500' : 'border-gray-300'
          } px-3 py-2`}
          value={formData.primary_level_id}
          onChange={(e) => setFormData({ ...formData, primary_level_id: e.target.value })}
        >
          <option value="">Select Primary Level</option>
          {levels
            .filter(level => formData.level_ids.includes(level.id))
            .map((level) => (
              <option key={level.id} value={level.id}>{level.name}</option>
            ))}
        </select>
        {errors.primary_level_id && <p className="mt-1 text-sm text-red-500">{errors.primary_level_id}</p>}
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Join Date</label>
          <input
            type="date"
            required
            className={`mt-1 block w-full rounded-md border ${
              errors.join_date ? 'border-red-500' : 'border-gray-300'
            } px-3 py-2`}
            value={formData.join_date}
            onChange={(e) => setFormData({ ...formData, join_date: e.target.value })}
          />
          {errors.join_date && <p className="mt-1 text-sm text-red-500">{errors.join_date}</p>}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700">Status</label>
          <select
            required
            className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as StaffFormData['status'] })}
          >
            <option value="probation">Probation</option>
            <option value="permanent">Permanent</option>
            <option value="resigned">Resigned</option>
          </select>
        </div>
      </div>

      <div className="flex justify-end space-x-3 pt-4">
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
          {initialData ? 'Update Staff' : 'Create Staff'}
        </button>
      </div>
    </form>
  );
}