import React, { createContext, useContext, ReactNode, useState, useEffect, useMemo } from 'react';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

// Define the context type
type SupabaseContextType = SupabaseClient | null;

// Create the context
const SupabaseContext = createContext<SupabaseContextType>(null);

// Initialize Supabase client
const supabaseManagerUrl = import.meta.env.VITE_MANAGER_SUPABASE_URL;
const supabaseManagerKey = import.meta.env.VITE_MANAGER_SUPABASE_ANON_KEY;
const supabaseManager: SupabaseClient = createClient(supabaseManagerUrl, supabaseManagerKey);

// Supabase Provider Props
interface SupabaseProviderProps {
  children: ReactNode;
}

// Supabase Provider Component
export const SupabaseProvider: React.FC<SupabaseProviderProps> = ({
  children,
}) => {
  const [supabaseUrl, setSupabaseUrl] = useState('');
  const [supabaseKey, setSupabaseKey] = useState('');
  
  useEffect(() => {
    const fetchSupabaseEnv = async () => {
      try {
        const link = window.location.host;
        const slug = link.split('.hrboast.com').length > 1 ? link.split('.hrboast.com')[0] : 'mtb';
        console.log("slug >>", slug);
  
        const { data, error } = await supabaseManager
          .from('hrboasts')
          .select('*')
          .eq('slug', slug)
          .single();
  
        if (error) {
          throw error;
        }
  
        setSupabaseUrl(data.supabase_url);
        setSupabaseKey(data.supabase_anon_key);
      } catch (error) {
        console.error('Error fetching tenant data:', error);
      }
    };

    fetchSupabaseEnv();
  }, []);

  const supabase = useMemo(() => {
    if (!supabaseUrl || !supabaseKey) {
      return null;
    }

    return createClient(supabaseUrl, supabaseKey);
  }, [supabaseUrl, supabaseKey]);
  
  return (
    <SupabaseContext.Provider value={supabase}>
      {children}
    </SupabaseContext.Provider>
  );
};

// Custom Hook to Use Supabase
export const useSupabase = (): SupabaseClient => {
  const context = useContext(SupabaseContext);
  // if (!context) {
  //   throw new Error('useSupabase must be used within a SupabaseProvider');
  // }
  return context;
};
