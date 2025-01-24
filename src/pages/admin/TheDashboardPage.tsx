import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { 
  Building2, 
  Users, 
  Clock,
  CheckCircle,
  AlertCircle
} from 'lucide-react';
import { Link } from 'react-router-dom';

type DashboardStats = {
  totalCompanies: number;
  activeCompanies: number;
  trialCompanies: number;
  totalUsers: number;
  pendingApprovals: number;
};

export default function TheDashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    totalCompanies: 0,
    activeCompanies: 0,
    trialCompanies: 0,
    totalUsers: 0,
    pendingApprovals: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardStats();
  }, []);

  const loadDashboardStats = async () => {
    try {
      const [
        { data: companies },
        { data: users }
      ] = await Promise.all([
        supabase.from('companies').select('*'),
        supabase.from('staff').select('*')
      ]);

      setStats({
        totalCompanies: companies?.length || 0,
        activeCompanies: companies?.filter(c => c.subscription_status === 'active').length || 0,
        trialCompanies: companies?.filter(c => c.subscription_status === 'trial').length || 0,
        totalUsers: users?.length || 0,
        pendingApprovals: companies?.filter(c => !c.is_active).length || 0
      });
    } catch (error) {
      console.error('Error loading dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen p-4">
        <div className="animate-pulse text-gray-500">Loading dashboard...</div>
      </div>
    );
  }

  const statCards = [
    {
      title: 'Total Companies',
      value: stats.totalCompanies,
      icon: Building2,
      color: 'blue',
      link: '/admin/settings/companies'
    },
    {
      title: 'Active Companies',
      value: stats.activeCompanies,
      icon: CheckCircle,
      color: 'green',
      link: '/admin/settings/companies'
    },
    {
      title: 'Trial Companies',
      value: stats.trialCompanies,
      icon: Clock,
      color: 'yellow',
      link: '/admin/settings/companies'
    },
    {
      title: 'Total Users',
      value: stats.totalUsers,
      icon: Users,
      color: 'indigo',
      link: '/admin/settings/users'
    },
    {
      title: 'Pending Approvals',
      value: stats.pendingApprovals,
      icon: AlertCircle,
      color: 'red',
      link: '/admin/settings/companies'
    }
  ];

  const getColorClasses = (color: string) => {
    const colors = {
      blue: 'bg-blue-100 text-blue-600',
      green: 'bg-green-100 text-green-600',
      yellow: 'bg-yellow-100 text-yellow-600',
      indigo: 'bg-indigo-100 text-indigo-600',
      red: 'bg-red-100 text-red-600'
    };
    return colors[color as keyof typeof colors] || colors.blue;
  };

  return (
    <div className="p-4 md:p-6 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl md:text-2xl font-bold text-gray-900">The Dashboard</h1>
        <p className="text-xs md:text-sm text-gray-500">Overview of all companies and users</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-5 gap-4">
        {statCards.map((stat) => (
          <Link 
            key={stat.title}
            to={stat.link}
            className="bg-white p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-gray-500">{stat.title}</p>
                <p className="text-xl font-semibold mt-1">{stat.value}</p>
              </div>
              <div className={`p-3 rounded-lg ${getColorClasses(stat.color)}`}>
                <stat.icon className="h-5 w-5" />
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}