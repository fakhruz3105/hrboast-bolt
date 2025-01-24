import { createClient } from '@supabase/supabase-js';
import { toast } from 'react-hot-toast';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

// Create default client for public schema
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: false
  },
  global: {
    headers: {
      'Content-Type': 'application/json'
    }
  }
});

// Add global error handler for network issues
supabase.handleNetworkError = (error: any) => {
  console.error('Network error:', error);
  toast.error('Network connection error. Please check your internet connection.');
};

// Add retry logic for failed requests
supabase.handleFailedRequest = async (error: any, retryCount = 0) => {
  if (retryCount < 3 && error.message === 'Failed to fetch') {
    await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, retryCount)));
    return true; // Retry the request
  }
  return false; // Don't retry
};

// Test the connection
supabase.from('benefits').select('count').limit(1).single()
  .then(() => console.log('Supabase connection successful'))
  .catch(error => {
    console.error('Supabase connection error:', error);
    toast.error('Error connecting to database');
  });

export default supabase;