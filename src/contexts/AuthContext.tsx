import React, { createContext, useContext, useState, useEffect } from 'react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../providers/SupabaseProvider';

type User = {
  id: string;
  email: string;
  role: string;
  company_id?: string;
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  login: (email: string, password: string, rememberMe?: boolean) => Promise<{ user: User }>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType | null>(null);

// Demo users for development
const DEMO_USERS = {
  'admin@example.com': {
    id: '2',
    email: 'admin@example.com',
    role: 'admin',
    company_id: '11111111-1111-1111-1111-111111111111'
  },
  'staff@example.com': {
    id: '3',
    email: 'staff@example.com',
    role: 'staff',
    company_id: '11111111-1111-1111-1111-111111111111'
  },
  'super.admin@example.com': {
    id: '1',
    email: 'super.admin@example.com',
    role: 'super_admin'
  }
};

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const supabase = useSupabase();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for stored user in localStorage or sessionStorage
    const storedUser = localStorage.getItem('user') || sessionStorage.getItem('user');
    if (storedUser) {
      try {
        const parsedUser = JSON.parse(storedUser);
        setUser(parsedUser);
      } catch (error) {
        console.error('Error parsing stored user:', error);
        localStorage.removeItem('user');
        sessionStorage.removeItem('user');
      }
    }
    setLoading(false);
  }, []);

  const login = async (email: string, password: string, rememberMe = false): Promise<{ user: User }> => {
    try {
      // Check if password is kertas12
      if (password !== 'kertas12') {
        throw new Error('Invalid password');
      }

      // For demo users
      const demoUser = DEMO_USERS[email as keyof typeof DEMO_USERS];
      if (demoUser) {
        setUser(demoUser);
        // Store user based on rememberMe preference
        if (rememberMe) {
          localStorage.setItem('user', JSON.stringify(demoUser));
          sessionStorage.removeItem('user');
        } else {
          sessionStorage.setItem('user', JSON.stringify(demoUser));
          localStorage.removeItem('user');
        }
        return { user: demoUser };
      }

      // For super admin
      if (email === 'super.admin@example.com') {
        const { data: staffData, error: staffError } = await supabase
          .from('staff')
          .select(`
            id,
            email,
            role:role_id(
              id,
              role
            )
          `)
          .eq('email', email)
          .single();

        if (staffError) throw staffError;
        if (!staffData) throw new Error('Super admin not found');

        const user = {
          id: staffData.id,
          email: staffData.email,
          role: 'super_admin' // Force role to super_admin
        };

        setUser(user);
        if (rememberMe) {
          localStorage.setItem('user', JSON.stringify(user));
          sessionStorage.removeItem('user');
        } else {
          sessionStorage.setItem('user', JSON.stringify(user));
          localStorage.removeItem('user');
        }
        return { user };
      }

      // For company admin
      const { data: companyData, error: companyError } = await supabase
        .from('companies')
        .select('id, name, email, is_active')
        .eq('email', email)
        .maybeSingle();

      if (!companyError && companyData) {
        if (!companyData.is_active) {
          throw new Error('Company account is inactive');
        }

        const user = {
          id: companyData.id,
          email: companyData.email,
          role: 'admin',
          company_id: companyData.id
        };

        setUser(user);
        if (rememberMe) {
          localStorage.setItem('user', JSON.stringify(user));
          sessionStorage.removeItem('user');
        } else {
          sessionStorage.setItem('user', JSON.stringify(user));
          localStorage.removeItem('user');
        }
        return { user };
      }

      // For staff
      const { data: staffData, error: staffError } = await supabase
        .from('staff')
        .select(`
          id,
          email,
          company_id,
          role:role_id(role),
          is_active
        `)
        .eq('email', email)
        .maybeSingle();

      if (staffError) {
        console.error('Staff lookup error:', staffError);
        throw new Error('Invalid credentials');
      }

      if (!staffData) {
        throw new Error('Invalid credentials');
      }

      if (!staffData.is_active) {
        throw new Error('Account is inactive');
      }

      const user = {
        id: staffData.id,
        email: staffData.email,
        role: staffData.role?.role || 'staff',
        company_id: staffData.company_id
      };

      setUser(user);
      if (rememberMe) {
        localStorage.setItem('user', JSON.stringify(user));
        sessionStorage.removeItem('user');
      } else {
        sessionStorage.setItem('user', JSON.stringify(user));
        localStorage.removeItem('user');
      }
      return { user };

    } catch (error) {
      const message = error instanceof Error ? error.message : 'Login failed';
      toast.error(message);
      throw error;
    }
  };

  const logout = async () => {
    try {
      setUser(null);
      localStorage.removeItem('user');
      sessionStorage.removeItem('user');
    } catch (error) {
      console.error('Logout error:', error);
      throw new Error('Logout failed');
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}