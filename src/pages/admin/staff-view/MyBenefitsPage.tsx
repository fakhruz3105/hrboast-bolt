import React, { useState, useEffect } from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import { Gift, Filter } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

type Benefit = {
  id: string;
  name: string;
  description: string;
  amount: number;
  status: boolean;
  frequency: string;
  is_eligible: boolean;
};

export default function MyBenefitsPage() {
  const supabase = useSupabase();
  const { staff } = useStaffProfile();
  const [benefits, setBenefits] = useState<Benefit[]>([]);
  const [loading, setLoading] = useState(true);
  const [showEligibleOnly, setShowEligibleOnly] = useState(true);

  useEffect(() => {
    if (staff?.id) {
      loadBenefits();
    }
  }, [staff?.id]);

  const loadBenefits = async () => {
    try {
      const { data, error } = await supabase.rpc('get_staff_eligible_benefits', {
        staff_uid: staff!.id
      });

      if (error) throw error;
      setBenefits(data || []);
    } catch (error) {
      console.error('Error loading benefits:', error);
      toast.error('Failed to load benefits');
    } finally {
      setLoading(false);
    }
  };

  const filteredBenefits = showEligibleOnly 
    ? benefits.filter(b => b.is_eligible)
    : benefits;

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-48 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="p-6">
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <Gift className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">Profile Not Found</h3>
          <p className="mt-1 text-sm text-gray-500">Unable to load your profile information.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="mb-8">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">My Benefits</h1>
            <p className="mt-1 text-sm text-gray-500">View your available benefits</p>
          </div>
          <button
            onClick={() => setShowEligibleOnly(!showEligibleOnly)}
            className={`inline-flex items-center px-4 py-2 rounded-lg border ${
              showEligibleOnly 
                ? 'bg-indigo-50 text-indigo-700 border-indigo-200'
                : 'bg-white text-gray-700 border-gray-300'
            } hover:bg-indigo-100 transition-colors`}
          >
            <Filter className="h-4 w-4 mr-2" />
            {showEligibleOnly ? 'Show All Benefits' : 'Show Eligible Only'}
          </button>
        </div>
      </div>

      <div className="grid gap-6">
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">Available Benefits</h2>
          {filteredBenefits.length > 0 ? (
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredBenefits.map((benefit) => (
                <div key={benefit.id} className="bg-white p-6 rounded-lg shadow hover:shadow-lg transition-shadow duration-200">
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="text-lg font-medium text-gray-900">{benefit.name}</h3>
                      <p className="mt-1 text-sm text-gray-500">{benefit.description}</p>
                      <p className="mt-2 text-lg font-semibold text-indigo-600">
                        RM {benefit.amount.toFixed(2)}
                      </p>
                      <p className="mt-1 text-sm text-gray-500">
                        {benefit.frequency}
                      </p>
                    </div>
                    <div className="bg-indigo-100 p-2 rounded-full">
                      <Gift className="h-5 w-5 text-indigo-600" />
                    </div>
                  </div>
                  {!benefit.is_eligible && (
                    <div className="mt-4 bg-red-50 text-red-600 text-sm p-2 rounded">
                      Not eligible for your position
                    </div>
                  )}
                  {!benefit.status && (
                    <div className="mt-4 bg-yellow-50 text-yellow-600 text-sm p-2 rounded">
                      Currently inactive
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-gray-50 border-2 border-dashed border-gray-200 rounded-lg p-8 text-center">
              <p className="text-gray-500">
                {showEligibleOnly 
                  ? 'No eligible benefits are currently available for your position.'
                  : 'No benefits are currently available.'}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}