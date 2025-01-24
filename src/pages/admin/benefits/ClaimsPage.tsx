import React, { useState, useEffect } from 'react';
import { supabase } from '../../../lib/supabase';
import { BenefitClaim } from '../../../types/benefit';
import ClaimsList from '../../../components/admin/benefits/claims/ClaimsList';
import ClaimViewer from '../../../components/admin/benefits/claims/ClaimViewer';

export default function ClaimsPage() {
  const [claims, setClaims] = useState<BenefitClaim[]>([]);
  const [selectedClaim, setSelectedClaim] = useState<BenefitClaim | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadClaims();
  }, []);

  const loadClaims = async () => {
    try {
      const { data, error } = await supabase
        .from('benefit_claims')
        .select(`
          *,
          benefit:benefit_id(*),
          staff:staff_id(
            id,
            name,
            department:departments(name)
          )
        `)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setClaims(data || []);
    } catch (error) {
      console.error('Error loading claims:', error);
      alert('Failed to load claims');
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateStatus = async (id: string, status: 'approved' | 'rejected') => {
    try {
      const { error } = await supabase
        .from('benefit_claims')
        .update({ status })
        .eq('id', id);

      if (error) throw error;
      await loadClaims();
    } catch (error) {
      console.error('Error updating claim status:', error);
      alert('Failed to update claim status');
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Benefit Claims</h1>
        <p className="mt-1 text-sm text-gray-500">Review and manage staff benefit claims</p>
      </div>

      <div className="bg-white rounded-lg shadow">
        <ClaimsList
          claims={claims}
          onView={setSelectedClaim}
          onUpdateStatus={handleUpdateStatus}
        />
      </div>

      {selectedClaim && (
        <ClaimViewer
          claim={selectedClaim}
          onClose={() => setSelectedClaim(null)}
        />
      )}
    </div>
  );
}