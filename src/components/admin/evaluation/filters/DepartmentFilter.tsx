import React from 'react';
import { Department } from '../../../../types/department';

type Props = {
  departments: Department[];
  selectedDepartment: string;
  onChange: (departmentId: string) => void;
};

export default function DepartmentFilter({ departments, selectedDepartment, onChange }: Props) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">Filter by Department</label>
      <select
        className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
        value={selectedDepartment}
        onChange={(e) => onChange(e.target.value)}
      >
        <option value="">All Departments</option>
        {departments.map((dept) => (
          <option key={dept.id} value={dept.id}>{dept.name}</option>
        ))}
      </select>
    </div>
  );
}