import React from 'react';
import EvaluationForm from '../../../components/admin/evaluation/EvaluationForm';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function CreateEvaluationPage() {
  const supabase = useSupabase();
  const handleSubmit = async (formData: {
    title: string;
    type: 'quarter' | 'half-year' | 'yearly';
    questions: Array<{
      id: string;
      category: string;
      question: string;
      description?: string;
      type: 'rating' | 'checkbox' | 'text';
      options?: string[];
    }>;
  }) => {
    try {
      const { error } = await supabase
        .from('evaluation_forms')
        .insert([formData]);

      if (error) throw error;

      alert('Evaluation form created successfully!');
    } catch (error) {
      console.error('Error creating evaluation form:', error);
      alert('Failed to create evaluation form');
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Create Evaluation Form</h1>
          <p className="text-gray-600 mt-1">Create a new evaluation form template</p>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <EvaluationForm onSubmit={handleSubmit} />
      </div>
    </div>
  );
}