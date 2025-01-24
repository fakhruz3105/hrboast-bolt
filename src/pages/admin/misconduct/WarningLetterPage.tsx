import React, { useState, useEffect } from 'react';
import { Plus } from 'lucide-react';
import { supabase } from '../../../lib/supabase';
import { useStaff } from '../../../hooks/useStaff';
import WarningLetterForm from '../../../components/admin/misconduct/warning/WarningLetterForm';
import WarningLetterList from '../../../components/admin/misconduct/warning/WarningLetterList';
import WarningLetterViewer from '../../../components/admin/misconduct/warning/WarningLetterViewer';
import { WarningLetterFormData } from '../../../types/warningLetter';
import { toast } from 'react-hot-toast';

export default function WarningLetterPage() {
  const { staff, loading: staffLoading } = useStaff();
  const [letters, setLetters] = useState<any[]>([]);
  const [showForm, setShowForm] = useState(false);
  const [viewingLetter, setViewingLetter] = useState<any>(null);
  const [editingLetter, setEditingLetter] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadWarningLetters();
  }, []);

  const loadWarningLetters = async () => {
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
        .eq('type', 'warning')
        .order('issued_date', { ascending: false });

      if (error) throw error;
      setLetters(data || []);
    } catch (error) {
      console.error('Error loading warning letters:', error);
      toast.error('Failed to load warning letters');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (formData: WarningLetterFormData) => {
    try {
      const { error } = await supabase.rpc('create_warning_letter', {
        p_staff_id: formData.staff_id,
        p_warning_level: formData.warning_level,
        p_incident_date: formData.incident_date,
        p_description: formData.description,
        p_improvement_plan: formData.improvement_plan,
        p_consequences: formData.consequences,
        p_issued_date: formData.issued_date
      });

      if (error) throw error;

      toast.success('Warning letter created successfully');
      setShowForm(false);
      loadWarningLetters();
    } catch (error) {
      console.error('Error creating warning letter:', error);
      toast.error('Failed to create warning letter');
    }
  };

  const handleEdit = async (letter: any) => {
    setEditingLetter(letter);
    setShowForm(true);
  };

  const handleDelete = async (letter: any) => {
    if (!window.confirm('Are you sure you want to delete this warning letter?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('hr_letters')
        .delete()
        .eq('id', letter.id)
        .eq('type', 'warning');

      if (error) throw error;

      toast.success('Warning letter deleted successfully');
      loadWarningLetters();
    } catch (error) {
      console.error('Error deleting warning letter:', error);
      toast.error('Failed to delete warning letter');
    }
  };

  const handleDownload = async (letter: any) => {
    // Implement PDF download functionality
    toast.success('Download functionality will be implemented soon');
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
          <h1 className="text-2xl font-bold text-gray-900">Warning Letters</h1>
          <p className="text-gray-600 mt-1">Manage staff warning letters</p>
        </div>
        <button
          onClick={() => {
            setEditingLetter(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          New Warning Letter
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <WarningLetterForm
            staff={staff}
            initialData={editingLetter}
            onSubmit={handleSubmit}
            onCancel={() => {
              setShowForm(false);
              setEditingLetter(null);
            }}
          />
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <WarningLetterList
          letters={letters}
          onView={setViewingLetter}
          onEdit={handleEdit}
          onDelete={handleDelete}
          onDownload={handleDownload}
        />
      </div>

      {viewingLetter && (
        <WarningLetterViewer
          letter={viewingLetter}
          onClose={() => setViewingLetter(null)}
        />
      )}
    </div>
  );
}