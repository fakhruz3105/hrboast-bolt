import React from 'react';
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import Sidebar from '../components/admin/Sidebar';
import HeaderInfo from '../components/admin/HeaderInfo';
import { useAuth } from '../contexts/AuthContext';

export default function AdminLayout() {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <div className="flex justify-center items-center min-h-screen">Loading...</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar - z-index 50 */}
      <Sidebar userRole={user.role} />
      {/* Header - z-index 40 */}
      <HeaderInfo />
      <main className="lg:ml-64 pt-16">
        <div className="p-4 lg:p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}