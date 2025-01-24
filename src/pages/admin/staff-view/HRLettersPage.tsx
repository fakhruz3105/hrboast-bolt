import React, { useState, useEffect } from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import { FileText, AlertCircle, Search, Filter, Clock, CheckCircle } from 'lucide-react';
import LetterViewer from '../../../components/admin/staff-view/letters/LetterViewer';
import { Letter } from '../../../types/letter';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

type LetterType = 'warning' | 'interview' | 'show_cause' | 'all';

export default function HRLettersPage() {
  const supabase = useSupabase();
  const { staff } = useStaffProfile();
  const [letters, setLetters] = useState<Letter[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLetter, setSelectedLetter] = useState<Letter | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedType, setSelectedType] = useState<LetterType>('all');
  const [selectedStatus, setSelectedStatus] = useState<string>('all');

  useEffect(() => {
    if (staff?.id) {
      loadLetters();
    }
  }, [staff?.id]);

  const loadLetters = async () => {
    try {
      const { data, error } = await supabase
        .from('hr_letters')
        .select('*')
        .eq('staff_id', staff!.id)
        .order('issued_date', { ascending: false });

      if (error) throw error;
      setLetters(data || []);
    } catch (error) {
      console.error('Error loading letters:', error);
      toast.error('Failed to load letters');
    } finally {
      setLoading(false);
    }
  };

  const handleLetterSubmitted = async () => {
    await loadLetters();
    setSelectedLetter(null);
    toast.success('Response submitted successfully');
  };

  const getLetterTypeIcon = (type: string) => {
    switch (type) {
      case 'warning':
        return <AlertCircle className="h-5 w-5" />;
      case 'interview':
        return <FileText className="h-5 w-5" />;
      case 'show_cause':
        return <AlertCircle className="h-5 w-5" />;
      default:
        return <FileText className="h-5 w-5" />;
    }
  };

  const getLetterTypeColor = (type: string) => {
    switch (type) {
      case 'warning':
        return 'bg-red-100 text-red-800 ring-red-200';
      case 'interview':
        return 'bg-blue-100 text-blue-800 ring-blue-200';
      case 'show_cause':
        return 'bg-amber-100 text-amber-800 ring-amber-200';
      default:
        return 'bg-gray-100 text-gray-800 ring-gray-200';
    }
  };

  const getLetterTypeLabel = (type: string) => {
    switch (type) {
      case 'warning':
        return 'Warning Letter';
      case 'interview':
        return 'Interview Form';
      case 'show_cause':
        return 'Show Cause Letter';
      default:
        return type;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'completed':
      case 'submitted':
        return 'bg-green-100 text-green-800';
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const filteredLetters = letters.filter(letter => {
    const matchesSearch = searchTerm === '' || 
      letter.title.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesType = selectedType === 'all' || letter.type === selectedType;
    const matchesStatus = selectedStatus === 'all' || letter.status === selectedStatus;
    
    return matchesSearch && matchesType && matchesStatus;
  });

  // Get letter statistics
  const stats = {
    total: letters.length,
    pending: letters.filter(l => l.status === 'pending').length,
    completed: letters.filter(l => ['completed', 'submitted'].includes(l.status)).length
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-3 gap-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-24 bg-gray-200 rounded-lg"></div>
            ))}
          </div>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-2xl font-bold text-gray-900 mb-6">Letters from HR</h1>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-indigo-100 text-indigo-600">
                <FileText className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Total Letters</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.total}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-yellow-100 text-yellow-600">
                <Clock className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Pending Action</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.pending}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="p-3 rounded-lg bg-green-100 text-green-600">
                <CheckCircle className="h-6 w-6" />
              </div>
              <div className="ml-4">
                <p className="text-sm font-medium text-gray-500">Completed</p>
                <p className="text-2xl font-semibold text-gray-900">{stats.completed}</p>
              </div>
            </div>
          </div>
        </div>

        {/* Search and Filters */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            {/* Search */}
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Search className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                placeholder="Search letters..."
                className="pl-10 block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>

            {/* Type Filter */}
            <div>
              <select
                className="block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                value={selectedType}
                onChange={(e) => setSelectedType(e.target.value as LetterType)}
              >
                <option value="all">All Types</option>
                <option value="warning">Warning Letters</option>
                <option value="interview">Interview Forms</option>
                <option value="show_cause">Show Cause Letters</option>
              </select>
            </div>

            {/* Status Filter */}
            <div>
              <select
                className="block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value)}
              >
                <option value="all">All Status</option>
                <option value="pending">Pending</option>
                <option value="completed">Completed</option>
                <option value="submitted">Submitted</option>
              </select>
            </div>
          </div>
        </div>

        {/* Letters List */}
        <div className="space-y-4">
          {filteredLetters.length > 0 ? (
            filteredLetters.map((letter) => (
              <div 
                key={letter.id}
                className="bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200 cursor-pointer"
                onClick={() => setSelectedLetter(letter)}
              >
                <div className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className={`p-3 rounded-lg ${getLetterTypeColor(letter.type)}`}>
                        {getLetterTypeIcon(letter.type)}
                      </div>
                      <div>
                        <h3 className="text-lg font-medium text-gray-900">{letter.title}</h3>
                        <div className="flex items-center mt-1 space-x-3">
                          <span className="text-sm text-gray-500">
                            {new Date(letter.issued_date).toLocaleDateString(undefined, {
                              year: 'numeric',
                              month: 'long',
                              day: 'numeric'
                            })}
                          </span>
                          <span className="text-gray-300">•</span>
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getLetterTypeColor(letter.type)}`}>
                            {getLetterTypeLabel(letter.type)}
                          </span>
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getStatusColor(letter.status)}`}>
                            {letter.status.charAt(0).toUpperCase() + letter.status.slice(1)}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="text-indigo-600">
                      <FileText className="h-5 w-5" />
                    </div>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="text-center py-12 bg-white rounded-lg shadow-sm">
              <FileText className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No letters found</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchTerm || selectedType !== 'all' || selectedStatus !== 'all'
                  ? 'No letters match your search criteria'
                  : 'You have no letters at the moment'}
              </p>
            </div>
          )}
        </div>
      </div>

      {selectedLetter && (
        <LetterViewer
          letter={selectedLetter}
          onClose={() => setSelectedLetter(null)}
          onSubmit={handleLetterSubmitted}
        />
      )}
    </div>
  );
}