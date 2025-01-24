import React from 'react';
import { Eye, Trash2, Download } from 'lucide-react';
import { ShowCauseLetter } from '../../../../types/showCause';
import { generateShowCauseLetterPDF } from '../../../../utils/showCauseLetterPDF';
import { toast } from 'react-hot-toast';

type Props = {
  letters: ShowCauseLetter[];
  onView: (letter: ShowCauseLetter) => void;
  onDelete: (id: string) => void;
};

const TYPE_LABELS: Record<string, string> = {
  lateness: 'Lateness',
  harassment: 'Harassment',
  leave_without_approval: 'Leave without Approval',
  offensive_behavior: 'Offensive Behavior',
  insubordination: 'Insubordination',
  misconduct: 'Other Misconduct'
};

export default function ShowCauseList({ letters, onView, onDelete }: Props) {
  const handleDelete = async (letter: ShowCauseLetter) => {
    if (window.confirm(`Are you sure you want to delete this show cause letter for ${letter.staff?.name}?`)) {
      await onDelete(letter.id);
    }
  };

  const handleDownload = async (letter: ShowCauseLetter) => {
    try {
      generateShowCauseLetterPDF(letter);
      toast.success('Show cause letter downloaded successfully');
    } catch (error) {
      console.error('Error downloading show cause letter:', error);
      toast.error('Failed to download show cause letter');
    }
  };

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Incident Date</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
            <th scope="col" className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider w-32">Actions</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {letters.map((letter) => (
            <tr key={letter.id} className="hover:bg-gray-50">
              <td className="px-6 py-4 whitespace-nowrap">
                <div className="text-sm font-medium text-gray-900">{letter.staff?.name}</div>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {letter.staff?.departments?.[0]?.department?.name}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="px-2 py-1 text-xs font-medium rounded-full bg-gray-100 text-gray-800">
                  {TYPE_LABELS[letter.content?.type] || letter.content?.title}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {new Date(letter.content?.incident_date).toLocaleDateString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                  letter.status === 'submitted' 
                    ? 'bg-green-100 text-green-800'
                    : 'bg-yellow-100 text-yellow-800'
                }`}>
                  {letter.status === 'submitted' ? 'Responded' : 'Pending'}
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
                    onClick={() => handleDownload(letter)}
                    className="text-green-600 hover:text-green-900"
                    title="Download Letter"
                  >
                    <Download className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(letter)}
                    className="text-red-600 hover:text-red-900"
                    title="Delete Letter"
                  >
                    <Trash2 className="h-4 w-4" />
                  </button>
                </div>
              </td>
            </tr>
          ))}
          {letters.length === 0 && (
            <tr>
              <td colSpan={6} className="px-6 py-4 text-center text-sm text-gray-500">
                No show cause letters found
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}