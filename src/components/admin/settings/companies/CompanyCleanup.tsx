import React, { useState } from 'react';
import { Trash2, RefreshCw, AlertCircle } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../../providers/SupabaseProvider';

type Props = {
  companyId: string;
  onCleanupComplete: () => void;
};

type CleanupType = 'inactive_staff' | 'expired_benefits' | 'old_evaluations' | 'old_warnings' | 'old_memos' | 'all';

export default function CompanyCleanup({ companyId, onCleanupComplete }: Props) {
  const supabase = useSupabase();
  const [showConfirm, setShowConfirm] = useState(false);
  const [selectedType, setSelectedType] = useState<CleanupType>('all');
  const [loading, setLoading] = useState(false);

  const cleanupTypes = [
    { value: 'inactive_staff', label: 'Inactive Staff' },
    { value: 'expired_benefits', label: 'Expired Benefits' },
    { value: 'old_evaluations', label: 'Old Evaluations' },
    { value: 'old_warnings', label: 'Old Warning Letters' },
    { value: 'old_memos', label: 'Old Memos' },
    { value: 'all', label: 'All Data' }
  ] as const;

  const handleCleanup = async () => {
    try {
      setLoading(true);

      const { data, error } = await supabase.rpc('cleanup_company_data', {
        p_company_id: companyId,
        p_cleanup_type: selectedType
      });

      if (error) throw error;

      // Show cleanup results
      data.forEach((result: any) => {
        toast.success(`${result.cleanup_type}: ${result.details}`);
      });

      onCleanupComplete();
      setShowConfirm(false);
    } catch (error) {
      console.error('Error cleaning up data:', error);
      toast.error('Failed to clean up data');
    } finally {
      setLoading(false);
    }
  };

  return (
    <>
      <button
        onClick={() => setShowConfirm(true)}
        className="inline-flex items-center px-3 py-2 border border-red-300 text-sm font-medium rounded-md text-red-700 bg-white hover:bg-red-50"
      >
        <Trash2 className="h-4 w-4 mr-2" />
        Cleanup Data
      </button>

      {showConfirm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <div className="flex items-start mb-4">
              <div className="flex-shrink-0">
                <AlertCircle className="h-6 w-6 text-red-600" />
              </div>
              <div className="ml-3">
                <h3 className="text-lg font-medium text-gray-900">
                  Confirm Data Cleanup
                </h3>
                <p className="text-sm text-gray-500 mt-1">
                  This action will permanently remove old or inactive data. Please select what you want to clean up:
                </p>
              </div>
            </div>

            <div className="mt-4">
              <select
                value={selectedType}
                onChange={(e) => setSelectedType(e.target.value as CleanupType)}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              >
                {cleanupTypes.map((type) => (
                  <option key={type.value} value={type.value}>
                    {type.label}
                  </option>
                ))}
              </select>

              <div className="mt-4 bg-yellow-50 border border-yellow-200 rounded-md p-4">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <AlertCircle className="h-5 w-5 text-yellow-400" />
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-yellow-800">
                      Warning
                    </h3>
                    <div className="mt-2 text-sm text-yellow-700">
                      <p>This will remove:</p>
                      <ul className="list-disc pl-5 mt-1 space-y-1">
                        {selectedType === 'all' ? (
                          <>
                            <li>All inactive staff records</li>
                            <li>All expired benefits</li>
                            <li>Evaluations older than 1 year</li>
                            <li>Warning letters older than 2 years</li>
                            <li>Memos older than 1 year</li>
                          </>
                        ) : selectedType === 'inactive_staff' ? (
                          <li>All staff records marked as inactive</li>
                        ) : selectedType === 'expired_benefits' ? (
                          <li>All benefits marked as inactive</li>
                        ) : selectedType === 'old_evaluations' ? (
                          <li>All completed evaluations older than 1 year</li>
                        ) : selectedType === 'old_warnings' ? (
                          <li>All warning letters older than 2 years</li>
                        ) : (
                          <li>All memos older than 1 year</li>
                        )}
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="mt-6 flex justify-end space-x-3">
              <button
                type="button"
                onClick={() => setShowConfirm(false)}
                disabled={loading}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleCleanup}
                disabled={loading}
                className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700"
              >
                {loading ? (
                  <>
                    <RefreshCw className="animate-spin h-4 w-4 mr-2" />
                    Cleaning...
                  </>
                ) : (
                  <>
                    <Trash2 className="h-4 w-4 mr-2" />
                    Clean Up Data
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}