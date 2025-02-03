import React from 'react';
import { Eye, Edit, Trash2, Download } from 'lucide-react';
import { generateWarningLetterPDF } from '../../../../utils/warningLetterPDF';
import { toast } from 'react-hot-toast';

type Props = {
  company: string;
  letters: any[];
  onView: (letter: any) => void;
  onEdit: (letter: any) => void;
  onDelete: (letter: any) => void;
  onDownload: (letter: any) => void;
};

export default function WarningLetterList({ company, letters, onView, onEdit, onDelete, onDownload }: Props) {
  const getPrimaryDepartment = (staff: any) => {
    if (!staff?.departments) return 'N/A';
    const primaryDept = staff.departments.find((d: any) => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const handleDelete = async (letter: any) => {
    if (!window.confirm(`Are you sure you want to delete this warning letter for ${letter.staff?.name}?`)) {
      return;
    }

    try {
      await onDelete(letter);
      toast.success('Warning letter deleted successfully');
    } catch (error) {
      console.error('Error deleting warning letter:', error);
      toast.error('Failed to delete warning letter');
    }
  };

  const handleDownload = (letter: any) => {
    try {
      // Transform the letter data to match the expected format
      const transformedLetter = {
        staff: letter.staff,
        content: {
          warning_level: letter.content.warning_level,
          incident_date: letter.content.incident_date,
          description: letter.content.description,
          improvement_plan: letter.content.improvement_plan,
          consequences: letter.content.consequences
        },
        issued_date: letter.issued_date
      };

      generateWarningLetterPDF(company, transformedLetter);
      toast.success('Warning letter downloaded successfully');
    } catch (error) {
      console.error('Error downloading warning letter:', error);
      toast.error('Failed to download warning letter');
    }
  };

  const getWarningLevelBadgeColor = (level: string) => {
    switch (level?.toLowerCase()) {
      case 'final':
        return 'bg-red-100 text-red-800';
      case 'second':
        return 'bg-yellow-100 text-yellow-800';
      default:
        return 'bg-blue-100 text-blue-800';
    }
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Warning Level</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Incident Date</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Issue Date</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Response</th>
            <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {letters.map((letter) => {
            const warningLevel = letter.content?.warning_level;
            return (
              <tr key={letter.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm font-medium text-gray-900">{letter.staff?.name}</div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {getPrimaryDepartment(letter.staff)}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${getWarningLevelBadgeColor(warningLevel)}`}>
                    {warningLevel?.toUpperCase()} WARNING
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {letter.content?.incident_date ? new Date(letter.content.incident_date).toLocaleDateString() : 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {letter.issued_date ? new Date(letter.issued_date).toLocaleDateString() : 'N/A'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    letter.content?.response 
                      ? 'bg-green-100 text-green-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {letter.content?.response ? 'Responded' : 'Pending'}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex justify-end space-x-2">
                    <button
                      onClick={() => onView(letter)}
                      className="text-indigo-600 hover:text-indigo-900"
                      title="View Letter"
                    >
                      <Eye className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => onEdit(letter)}
                      className="text-blue-600 hover:text-blue-900"
                      title="Edit Letter"
                    >
                      <Edit className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(letter)}
                      className="text-red-600 hover:text-red-900"
                      title="Delete Letter"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDownload(letter)}
                      className="text-green-600 hover:text-green-900"
                      title="Download Letter"
                    >
                      <Download className="h-4 w-4" />
                    </button>
                  </div>
                </td>
              </tr>
            );
          })}
          {letters.length === 0 && (
            <tr>
              <td colSpan={7} className="px-6 py-4 text-center text-sm text-gray-500">
                No warning letters found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}