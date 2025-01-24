// Simple auth without Supabase authentication
const ADMIN_CREDENTIALS = {
  email: 'admin@example.com',
  password: 'admin123'
};

export async function signInWithEmail(email: string, password: string) {
  // Simple credential check
  if (email === ADMIN_CREDENTIALS.email && password === ADMIN_CREDENTIALS.password) {
    return {
      user: {
        id: '1',
        email,
        role: 'admin'
      }
    };
  }
  throw new Error('Invalid credentials');
}

export async function signOut() {
  // Simple sign out
  return Promise.resolve();
}

export async function getCurrentUser() {
  // Get user from localStorage
  const userStr = localStorage.getItem('user');
  return userStr ? JSON.parse(userStr) : null;
}

export function isAdmin(user: any): boolean {
  return user?.role === 'admin';
}