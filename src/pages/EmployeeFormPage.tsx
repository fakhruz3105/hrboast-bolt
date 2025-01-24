import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { supabase } from '../lib/supabase';
import EmployeeForm from '../components/staff/EmployeeForm';

export default function EmployeeFormPage() {
  const { formId } = useParams();
  const [formRequest, setFormRequest] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadFormRequest();
  }, [formId]);

  const loadFormRequest = async () => {
    try {
      const { data, error } = await supabase
        .from('employee_form_requests')
        .select('*')
        .eq('form_link', formId)
        .maybeSingle();

      if (error) throw error;
      if (!data) throw new Error('Form not found');
      
      // Check if form has expired
      if (new Date(data.expires_at) < new Date()) {
        throw new Error('Form has expired');
      }

      setFormRequest(data);
    } catch (error) {
      console.error('Error loading form:', error);
      setError(error instanceof Error ? error.message : 'Form not found or has expired');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <div className="w-full max-w-md">
          <div className="bg-white shadow rounded-lg p-6 animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
            <div className="space-y-3">
              <div className="h-4 bg-gray-200 rounded"></div>
              <div className="h-4 bg-gray-200 rounded w-5/6"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center px-4">
        <div className="bg-white p-8 rounded-lg shadow-md max-w-md w-full text-center">
          <h1 className="text-2xl font-bold text-gray-900 mb-4">Error</h1>
          <p className="text-gray-600">{error}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4">
      <div className="max-w-3xl mx-auto">
        <div className="bg-white shadow rounded-lg p-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">Employee Information Form</h1>
          <EmployeeForm formRequest={formRequest} />
        </div>
      </div>
    </div>
  );
}