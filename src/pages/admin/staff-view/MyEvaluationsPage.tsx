import React, { useState, useEffect } from 'react';
import { EvaluationResponse } from '../../../types/evaluation';
import { useAuth } from '../../../contexts/AuthContext';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import EvaluationsList from '../../../components/admin/staff-view/evaluations/EvaluationsList';
import EvaluationDetails from '../../../components/admin/staff-view/evaluations/EvaluationDetails';
import SelfEvaluationForm from '../../../components/admin/staff-view/evaluations/SelfEvaluationForm';
import EvaluationStats from '../../../components/admin/staff-view/evaluations/EvaluationStats';
import { Table as Tabs } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function MyEvaluationsPage() {
  const supabase = useSupabase();
  const { staff } = useStaffProfile();
  const [myEvaluations, setMyEvaluations] = useState<EvaluationResponse[]>([]);
  const [teamEvaluations, setTeamEvaluations] = useState<EvaluationResponse[]>([]);
  const [selectedEvaluation, setSelectedEvaluation] = useState<EvaluationResponse | null>(null);
  const [evaluationToStart, setEvaluationToStart] = useState<EvaluationResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'my' | 'team'>('my');

  useEffect(() => {
    if (staff?.id) {
      loadEvaluations(staff.id);
    }
  }, [staff?.id]);

  const loadEvaluations = async (staffId: string) => {
    setLoading(true);
    try {
      await Promise.all([
        loadMyEvaluations(staffId),
        loadTeamEvaluations(staffId)
      ]);
    } catch (error) {
      console.error('Error loading evaluations:', error);
      toast.error('Failed to load evaluations');
    } finally {
      setLoading(false);
    }
  };

  const loadMyEvaluations = async (staffId: string) => {
    const { data, error } = await supabase
      .from('evaluation_responses')
      .select(`
        *,
        evaluation:evaluation_id(*),
        staff:staff_id(
          id, 
          name,
          departments:staff_departments(
            id,
            is_primary,
            department:departments(name)
          )
        ),
        manager:manager_id(id, name)
      `)
      .eq('staff_id', staffId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    setMyEvaluations(data || []);
  };

  const loadTeamEvaluations = async (staffId: string) => {
    const { data, error } = await supabase
      .from('evaluation_responses')
      .select(`
        *,
        evaluation:evaluation_id(*),
        staff:staff_id(
          id, 
          name,
          departments:staff_departments(
            id,
            is_primary,
            department:departments(name)
          )
        ),
        manager:manager_id(id, name)
      `)
      .eq('manager_id', staffId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    setTeamEvaluations(data || []);
  };

  const handleSubmitSelfEvaluation = async (responses: Record<string, any>) => {
    if (!evaluationToStart || !staff?.id) return;

    try {
      const { error } = await supabase
        .from('evaluation_responses')
        .update({
          self_ratings: responses.ratings,
          self_comments: responses.comments,
          status: 'completed',
          submitted_at: new Date().toISOString()
        })
        .eq('id', evaluationToStart.id)
        .eq('staff_id', staff.id);

      if (error) throw error;

      toast.success('Self evaluation submitted successfully!');
      setEvaluationToStart(null);
      await loadEvaluations(staff.id);
    } catch (error) {
      console.error('Error submitting evaluation:', error);
      toast.error('Failed to submit evaluation');
    }
  };

  const handleSubmitManagerEvaluation = async (responses: Record<string, any>) => {
    if (!evaluationToStart || !staff?.id) return;

    try {
      const { error } = await supabase
        .from('evaluation_responses')
        .update({
          manager_ratings: responses.ratings,
          manager_comments: responses.comments,
          status: 'completed',
          completed_at: new Date().toISOString()
        })
        .eq('id', evaluationToStart.id)
        .eq('manager_id', staff.id);

      if (error) throw error;

      toast.success('Manager evaluation submitted successfully!');
      setEvaluationToStart(null);
      await loadEvaluations(staff.id);
    } catch (error) {
      console.error('Error submitting evaluation:', error);
      toast.error('Failed to submit evaluation');
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="p-6">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">My Evaluations</h1>

        {/* Tab Navigation */}
        <div className="mb-6">
          <div className="border-b border-gray-200">
            <nav className="-mb-px flex space-x-8">
              <button
                onClick={() => setActiveTab('my')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'my'
                    ? 'border-indigo-500 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                My Evaluations ({myEvaluations.length})
              </button>
              <button
                onClick={() => setActiveTab('team')}
                className={`py-4 px-1 border-b-2 font-medium text-sm ${
                  activeTab === 'team'
                    ? 'border-indigo-500 text-indigo-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
                }`}
              >
                Team Evaluations ({teamEvaluations.length})
              </button>
            </nav>
          </div>
        </div>

        {/* Statistics Overview */}
        <div className="mb-8">
          <EvaluationStats evaluations={activeTab === 'my' ? myEvaluations : teamEvaluations} />
        </div>

        {/* Evaluations List */}
        <div className="bg-white rounded-lg shadow">
          <EvaluationsList
            evaluations={activeTab === 'my' ? myEvaluations : teamEvaluations}
            onView={setSelectedEvaluation}
            onStartSelfEvaluation={setEvaluationToStart}
          />
        </div>

        {selectedEvaluation && (
          <EvaluationDetails
            evaluation={selectedEvaluation}
            onClose={() => setSelectedEvaluation(null)}
          />
        )}

        {evaluationToStart && (
          <SelfEvaluationForm
            evaluation={evaluationToStart}
            onSubmit={activeTab === 'my' ? handleSubmitSelfEvaluation : handleSubmitManagerEvaluation}
            onClose={() => setEvaluationToStart(null)}
          />
        )}
      </div>
    </div>
  );
}