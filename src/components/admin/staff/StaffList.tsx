import React from 'react';
import { Staff } from '../../../types/staff';
import { Edit, Trash2 } from 'lucide-react';
import { toast } from 'react-hot-toast';

const STATUS_COLORS = {
  permanent: 'bg-green-100 text-green-800',
  probation: 'bg-yellow-100 text-yellow-800',
  resigned: 'bg-red-100 text-red-800'
};

export default function StaffList({ staff, onEdit, onDelete }: {
  staff: Staff[];
  onEdit: (staff: Staff) => void;
  onDelete: (id: string) => void;
}) {
  const getPrimaryDepartment = (staff: Staff) => {
    const primaryDept = staff.departments?.find(d => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const getOtherDepartments = (staff: Staff) => {
    return staff.departments
      ?.filter(d => !d.is_primary)
      .map(d => d.department?.name)
      .join(', ') || '';
  };

  const getPrimaryLevel = (staff: Staff) => {
    const primaryLevel = staff.levels?.find(l => l.is_primary);
    return primaryLevel?.level?.name || 'N/A';
  };

  const getOtherLevels = (staff: Staff) => {
    return staff.levels
      ?.filter(l => !l.is_primary)
      .map(l => l.level?.name)
      .join(', ') || '';
  };

  const handleDelete = async (staff: Staff) => {
    if (!window.confirm(`Are you sure you want to delete ${staff.name}?`)) {
      return;
    }

    try {
      await onDelete(staff.id);
      toast.success('Staff member deleted successfully');
    } catch (error) {
      console.error('Error deleting staff:', error);
      toast.error('Failed to delete staff member');
    }
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Primary Department</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Other Departments</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Primary Level</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Other Levels</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Join Date</th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {staff.map((member) => (
            <tr key={member.id}>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {member.name}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                <div>{member.email}</div>
                <div>{member.phone_number}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {getPrimaryDepartment(member)}
              </td>
              <td className="px-6 py-4 text-sm text-gray-500">
                {getOtherDepartments(member)}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {getPrimaryLevel(member)}
              </td>
              <td className="px-6 py-4 text-sm text-gray-500">
                {getOtherLevels(member)}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {new Date(member.join_date).toLocaleDateString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${STATUS_COLORS[member.status]}`}>
                  {member.status.charAt(0).toUpperCase() + member.status.slice(1)}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                <button
                  onClick={() => onEdit(member)}
                  className="text-indigo-600 hover:text-indigo-900 mr-3"
                >
                  <Edit className="h-4 w-4" />
                </button>
                <button
                  onClick={() => handleDelete(member)}
                  className="text-red-600 hover:text-red-900"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </td>
            </tr>
          ))}
          {staff.length === 0 && (
            <tr>
              <td colSpan={9} className="px-6 py-4 text-center text-sm text-gray-500">
                No staff members found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}