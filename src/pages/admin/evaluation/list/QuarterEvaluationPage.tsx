import React, { useState, useEffect } from 'react';
import { EvaluationForm, EvaluationResponse } from '../../../../types/evaluation';
import EvaluationList from '../../../../components/admin/evaluation/EvaluationList';
import EvaluationDetails from '../../../../components/admin/evaluation/EvaluationDetails';
import AssignmentForm from '../../../../components/admin/evaluation/assignment/AssignmentForm';
import AssignedEvaluationsList from '../../../../components/admin/evaluation/AssignedEvaluationsList';
import EvaluationResponseDetails from '../../../../components/admin/evaluation/details/EvaluationResponseDetails';
import EvaluationStats from '../../../../components/admin/evaluation/EvaluationStats';
import { useSupabase } from '../../../../providers/SupabaseProvider';
import { useAuth } from '../../../../contexts/AuthContext';

export default function QuarterEvaluationPage() {
  const supabase = useSupabase();
  const { company } = useAuth();
  const [evaluations, setEvaluations] = useState<EvaluationForm[]>([]);
  const [assignments, setAssignments] = useState<EvaluationResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewingEvaluation, setViewingEvaluation] = useState<EvaluationForm | null>(null);
  const [startingEvaluation, setStartingEvaluation] = useState<EvaluationForm | null>(null);
  const [viewingResponse, setViewingResponse] = useState<EvaluationResponse | null>(null);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        loadEvaluations(),
        loadAssignments()
      ]);
    } catch (error) {
      console.error('Error loading data:', error);
      alert('Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const loadEvaluations = async () => {
    const { data, error } = await supabase
      .from('evaluation_forms')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw error;
    setEvaluations(data || []);
  };

  const loadAssignments = async () => {
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
      .order('created_at', { ascending: false });

    if (error) throw error;
    setAssignments(data || []);
  };

  const handleAssignEvaluation = async (data: {
    departmentIds: string[];
    staffIds: string[];
    managerId: string;
  }) => {
    if (!startingEvaluation) return;

    try {
      const responses = data.staffIds.map(staffId => ({
        evaluation_id: startingEvaluation.id,
        staff_id: staffId,
        manager_id: data.managerId,
        status: 'pending',
        self_ratings: {},
        self_comments: {},
        manager_ratings: {},
        manager_comments: {}
      }));

      const { error } = await supabase
        .from('evaluation_responses')
        .insert(responses);

      if (error) throw error;

      alert('Evaluation assigned successfully!');
      setStartingEvaluation(null);
      await loadAssignments();
    } catch (error) {
      console.error('Error assigning evaluation:', error);
      alert('Failed to assign evaluation');
    }
  };

  const handleDeleteEvaluation = async (evaluation: EvaluationForm) => {
    try {
      const { error } = await supabase
        .from('evaluation_forms')
        .delete()
        .eq('id', evaluation.id);

      if (error) throw error;
      await loadEvaluations();
    } catch (error) {
      console.error('Error deleting evaluation:', error);
      alert('Failed to delete evaluation');
    }
  };

  const handleDeleteAssignment = async (assignment: EvaluationResponse) => {
    try {
      const { error } = await supabase
        .from('evaluation_responses')
        .delete()
        .eq('id', assignment.id);

      if (error) throw error;
      await loadAssignments();
    } catch (error) {
      console.error('Error deleting assignment:', error);
      alert('Failed to delete assignment');
    }
  };

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Evaluation List</h1>
          <p className="text-gray-600 mt-1">View and manage all evaluations</p>
        </div>
      </div>

      {/* Statistics Overview */}
      <div className="mb-8">
        <EvaluationStats evaluations={assignments} />
      </div>

      <div className="space-y-8">
        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">Evaluation Forms</h2>
          <div className="bg-white rounded-lg shadow">
            <EvaluationList
              evaluations={evaluations}
              onView={setViewingEvaluation}
              onStartEvaluation={setStartingEvaluation}
              onDelete={handleDeleteEvaluation}
            />
          </div>
        </div>

        <div>
          <h2 className="text-lg font-medium text-gray-900 mb-4">Assigned Evaluations</h2>
          <div className="bg-white rounded-lg shadow">
            <AssignedEvaluationsList
              company={company}
              assignments={assignments}
              onView={setViewingResponse}
              onDelete={handleDeleteAssignment}
            />
          </div>
        </div>
      </div>

      {viewingEvaluation && (
        <EvaluationDetails
          evaluation={viewingEvaluation}
          onClose={() => setViewingEvaluation(null)}
        />
      )}

      {startingEvaluation && (
        <AssignmentForm
          evaluation={startingEvaluation}
          onSubmit={handleAssignEvaluation}
          onCancel={() => setStartingEvaluation(null)}
        />
      )}

      {viewingResponse && (
        <EvaluationResponseDetails
          evaluation={viewingResponse}
          onClose={() => setViewingResponse(null)}
        />
      )}
    </div>
  );
}