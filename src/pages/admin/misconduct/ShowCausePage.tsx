import React, { useState, useEffect } from 'react';
import { Plus } from 'lucide-react';
import { useStaff } from '../../../hooks/useStaff';
import ShowCauseForm from '../../../components/admin/misconduct/show-cause/ShowCauseForm';
import ShowCauseList from '../../../components/admin/misconduct/show-cause/ShowCauseList';
import ShowCauseViewer from '../../../components/admin/misconduct/show-cause/ShowCauseViewer';
import { ShowCauseFormData } from '../../../types/showCause';
import { Letter } from '../../../types/letter';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';
import { useAuth } from '../../../contexts/AuthContext';

export default function ShowCausePage() {
  const supabase = useSupabase();
  const { company } = useAuth();
  const { staff, loading: staffLoading } = useStaff();
  const [letters, setLetters] = useState<Letter[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [viewingLetter, setViewingLetter] = useState<Letter | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadShowCauseLetters();
  }, []);

  const loadShowCauseLetters = async () => {
    try {
      const { data, error } = await supabase
        .from('hr_letters')
        .select(`
          *,
          staff:staff_id (
            name,
            departments:staff_departments(
              is_primary,
              department:departments(name)
            )
          )
        `)
        .eq('type', 'show_cause')
        .order('issued_date', { ascending: false });

      if (error) throw error;
      setLetters(data || []);
    } catch (error) {
      console.error('Error loading show cause letters:', error);
      toast.error('Failed to load show cause letters');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (formData: ShowCauseFormData) => {
    try {
      const { error } = await supabase.rpc('create_show_cause_letter', {
        p_staff_id: formData.staff_id,
        p_type: formData.type,
        p_title: formData.title,
        p_incident_date: formData.incident_date,
        p_description: formData.description
      });

      if (error) throw error;

      toast.success('Show cause letter created successfully');
      setShowForm(false);
      loadShowCauseLetters();
    } catch (error) {
      console.error('Error creating show cause letter:', error);
      toast.error('Failed to create show cause letter');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this show cause letter?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('hr_letters')
        .delete()
        .eq('id', id)
        .eq('type', 'show_cause');

      if (error) throw error;

      toast.success('Show cause letter deleted successfully');
      loadShowCauseLetters();
    } catch (error) {
      console.error('Error deleting show cause letter:', error);
      toast.error('Failed to delete show cause letter');
    }
  };

  if (loading || staffLoading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            <div className="h-12 bg-gray-200 rounded"></div>
            <div className="h-64 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Show Cause Letters</h1>
          <p className="text-gray-600 mt-1">Manage staff show cause letters</p>
        </div>
        <button
          onClick={() => setShowForm(true)}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          New Show Cause Letter
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <ShowCauseForm
            staff={staff}
            onSubmit={handleSubmit}
            onCancel={() => setShowForm(false)}
          />
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <ShowCauseList
          company={company}
          letters={letters}
          onView={setViewingLetter}
          onDelete={handleDelete}
        />
      </div>

      {viewingLetter && (
        <ShowCauseViewer
          letter={viewingLetter}
          onClose={() => setViewingLetter(null)}
        />
      )}
    </div>
  );
}