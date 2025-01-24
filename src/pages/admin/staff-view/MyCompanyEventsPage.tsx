import React, { useState, useEffect } from 'react';
import { Calendar } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

type Event = {
  id: string;
  title: string;
  description: string;
  quarter: 'Q1' | 'Q2' | 'Q3' | 'Q4';
  start_date: string;
  end_date: string;
  status: 'upcoming' | 'ongoing' | 'completed';
  created_at: string;
};

export default function MyCompanyEventsPage() {
  const supabase = useSupabase();
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadEvents();
  }, []);

  const loadEvents = async () => {
    try {
      const { data, error } = await supabase
        .from('company_events')
        .select('*')
        .order('start_date', { ascending: true });

      if (error) throw error;
      setEvents(data || []);
    } catch (error) {
      console.error('Error loading events:', error);
      toast.error('Failed to load events');
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'upcoming':
        return 'bg-blue-100 text-blue-800';
      case 'ongoing':
        return 'bg-green-100 text-green-800';
      case 'completed':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  if (loading) {
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
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">My Company Events</h1>
        <p className="mt-1 text-sm text-gray-500">View upcoming and ongoing company events</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {['Q1', 'Q2', 'Q3', 'Q4'].map((quarter) => (
          <div key={quarter} className="bg-white rounded-lg shadow">
            <div className="p-4 border-b border-gray-200">
              <h2 className="text-lg font-semibold text-gray-900">{quarter}</h2>
            </div>
            <div className="p-4 space-y-4">
              {events
                .filter((event) => event.quarter === quarter)
                .map((event) => (
                  <div
                    key={event.id}
                    className="bg-gray-50 rounded-lg p-4 hover:shadow-md transition-shadow"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <h3 className="font-medium text-gray-900">{event.title}</h3>
                        <p className="text-sm text-gray-500 mt-1">{event.description}</p>
                        <div className="flex items-center space-x-2 mt-2">
                          <Calendar className="h-4 w-4 text-gray-400" />
                          <span className="text-xs text-gray-500">
                            {new Date(event.start_date).toLocaleDateString()} - {new Date(event.end_date).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(event.status)}`}>
                        {event.status}
                      </span>
                    </div>
                  </div>
                ))}
              {events.filter((event) => event.quarter === quarter).length === 0 && (
                <div className="text-center py-4 text-gray-500 text-sm">
                  No events for {quarter}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}