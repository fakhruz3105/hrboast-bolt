import React from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

export default function PublicLayout() {
  const location = useLocation();
  const isLoginPage = location.pathname === '/login';

  return (
    <div className="min-h-screen flex flex-col">
      <Navbar />
      <div className={`flex-grow ${!isLoginPage && 'pt-16'}`}>
        <Outlet />
      </div>
      <Footer />
    </div>
  );
}