import React from 'react';
import { X } from 'lucide-react';
import { BenefitClaim } from '../../../../types/benefit';

type Props = {
  claim: BenefitClaim;
  onClose: () => void;
};

export default function ClaimViewer({ claim, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-2xl mx-auto rounded-xl shadow-lg">
          <div className="p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Benefit Claim Details</h2>
              <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
                <X className="h-6 w-6" />
              </button>
            </div>

            <div className="space-y-6">
              <div>
                <h3 className="text-lg font-medium text-gray-900">Staff Information</h3>
                <dl className="mt-2 grid grid-cols-2 gap-4">
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Name</dt>
                    <dd className="text-sm text-gray-900">{claim.staff?.name}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Department</dt>
                    <dd className="text-sm text-gray-900">{claim.staff?.department?.name}</dd>
                  </div>
                </dl>
              </div>

              <div>
                <h3 className="text-lg font-medium text-gray-900">Claim Details</h3>
                <dl className="mt-2 space-y-4">
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Benefit Type</dt>
                    <dd className="text-sm text-gray-900">{claim.benefit?.name}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Amount Claimed</dt>
                    <dd className="text-sm text-gray-900">RM {claim.amount.toFixed(2)}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Claim Date</dt>
                    <dd className="text-sm text-gray-900">{new Date(claim.claim_date).toLocaleDateString()}</dd>
                  </div>
                  <div>
                    <dt className="text-sm font-medium text-gray-500">Status</dt>
                    <dd className="text-sm">
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        claim.status === 'approved' ? 'bg-green-100 text-green-800' :
                        claim.status === 'rejected' ? 'bg-red-100 text-red-800' :
                        'bg-yellow-100 text-yellow-800'
                      }`}>
                        {claim.status.charAt(0).toUpperCase() + claim.status.slice(1)}
                      </span>
                    </dd>
                  </div>
                  {claim.notes && (
                    <div>
                      <dt className="text-sm font-medium text-gray-500">Notes</dt>
                      <dd className="text-sm text-gray-900">{claim.notes}</dd>
                    </div>
                  )}
                </dl>
              </div>

              {claim.receipt_url && (
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Receipt</h3>
                  <div className="mt-2">
                    <a
                      href={claim.receipt_url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-indigo-600 hover:text-indigo-900"
                    >
                      View Receipt
                    </a>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}