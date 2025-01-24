import React, { useState, useEffect } from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import { supabase } from '../../../lib/supabase';
import { Medal, Gift, TrendingUp, DollarSign, Search } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { Memo } from '../../../types/memo';

export default function MemoPage() {
  const { staff } = useStaffProfile();
  const [memos, setMemos] = useState<Memo[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedType, setSelectedType] = useState<string | null>(null);

  useEffect(() => {
    if (staff?.id) {
      loadMemos();
    }
  }, [staff?.id]);

  const loadMemos = async () => {
    try {
      if (!staff?.id) {
        toast.error('Staff profile not found');
        return;
      }

      const { data, error } = await supabase.rpc('get_staff_memo_list', {
        p_staff_id: staff.id
      });

      if (error) throw error;
      setMemos(data || []);
    } catch (error) {
      console.error('Error loading memos:', error);
      toast.error('Failed to load achievements');
    } finally {
      setLoading(false);
    }
  };

  const getMemoTypeIcon = (type: string) => {
    switch (type) {
      case 'recognition':
        return <Medal className="h-6 w-6" />;
      case 'rewards':
        return <Gift className="h-6 w-6" />;
      case 'bonus':
        return <TrendingUp className="h-6 w-6" />;
      case 'salary_increment':
        return <DollarSign className="h-6 w-6" />;
      default:
        return <Medal className="h-6 w-6" />;
    }
  };

  const getMemoTypeColor = (type: string) => {
    switch (type) {
      case 'recognition':
        return 'bg-purple-100 text-purple-800 ring-purple-200';
      case 'rewards':
        return 'bg-green-100 text-green-800 ring-green-200';
      case 'bonus':
        return 'bg-blue-100 text-blue-800 ring-blue-200';
      case 'salary_increment':
        return 'bg-amber-100 text-amber-800 ring-amber-200';
      default:
        return 'bg-gray-100 text-gray-800 ring-gray-200';
    }
  };

  const getMemoTypeLabel = (type: string) => {
    switch (type) {
      case 'recognition':
        return 'Recognition';
      case 'rewards':
        return 'Rewards';
      case 'bonus':
        return 'Bonus Eligible';
      case 'salary_increment':
        return 'Salary Increment';
      default:
        return type;
    }
  };

  const filteredMemos = memos.filter(memo => {
    const matchesSearch = searchTerm === '' || 
      memo.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      memo.content.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesType = !selectedType || memo.type === selectedType;
    
    return matchesSearch && matchesType;
  });

  const memoTypes = [
    { type: 'recognition', label: 'Recognition', icon: Medal },
    { type: 'rewards', label: 'Rewards', icon: Gift },
    { type: 'bonus', label: 'Bonus', icon: TrendingUp },
    { type: 'salary_increment', label: 'Increment', icon: DollarSign }
  ];

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="bg-gray-200 h-40 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-8">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">My Achievements</h1>
            <p className="mt-1 text-sm text-gray-500">View your recognitions and rewards</p>
          </div>

          {/* Search Bar */}
          <div className="relative w-full md:w-64">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search achievements..."
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
        </div>

        {/* Type Filters */}
        <div className="flex flex-wrap gap-2 mb-6">
          <button
            onClick={() => setSelectedType(null)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
              !selectedType
                ? 'bg-indigo-100 text-indigo-800 ring-2 ring-indigo-200'
                : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            }`}
          >
            All
          </button>
          {memoTypes.map(({ type, label, icon: Icon }) => (
            <button
              key={type}
              onClick={() => setSelectedType(selectedType === type ? null : type)}
              className={`inline-flex items-center px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                selectedType === type
                  ? getMemoTypeColor(type)
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
              }`}
            >
              <Icon className="h-4 w-4 mr-2" />
              {label}
            </button>
          ))}
        </div>

        {/* Achievements List */}
        <div className="space-y-6">
          {filteredMemos.length > 0 ? (
            filteredMemos.map((memo) => (
              <div 
                key={memo.id} 
                className="bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow duration-200 overflow-hidden"
              >
                <div className="p-6">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${getMemoTypeColor(memo.type)}`}>
                          {getMemoTypeIcon(memo.type)}
                          <span className="ml-2">{getMemoTypeLabel(memo.type)}</span>
                        </span>
                        <span className="text-sm text-gray-500">
                          {new Date(memo.created_at).toLocaleDateString(undefined, {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                          })}
                        </span>
                      </div>
                      <h3 className="text-xl font-semibold text-gray-900">{memo.title}</h3>
                      {(memo.department_name || memo.staff_name) && (
                        <p className="text-sm text-gray-600 mt-1">
                          {memo.department_name && `Department: ${memo.department_name}`}
                          {memo.staff_name && `Staff: ${memo.staff_name}`}
                          {!memo.department_name && !memo.staff_name && 'All Staff'}
                        </p>
                      )}
                    </div>
                  </div>
                  <div className="prose prose-sm max-w-none mt-4">
                    <p className="text-gray-700 whitespace-pre-wrap">{memo.content}</p>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="text-center py-12 bg-white rounded-xl shadow-sm">
              <Medal className="mx-auto h-12 w-12 text-gray-400" />
              <h3 className="mt-2 text-sm font-medium text-gray-900">No achievements yet</h3>
              <p className="mt-1 text-sm text-gray-500">
                {searchTerm || selectedType
                  ? 'No achievements match your search criteria'
                  : 'Your achievements will appear here'}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}