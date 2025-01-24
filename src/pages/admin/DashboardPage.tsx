import React, { useState, useEffect } from 'react';
import { supabase } from '../../lib/supabase';
import { 
  Calendar, 
  Building2, 
  UserCircle, 
  Clock, 
  FileText,
  TrendingUp,
  AlertCircle,
  CheckCircle,
  Gift,
  Mail,
  Users
} from 'lucide-react';
import { Link } from 'react-router-dom';

type DashboardStats = {
  totalStaff: number;
  totalDepartments: number;
  activeEvaluations: number;
  completedEvaluations: number;
  pendingWarnings: number;
  averageScore: number;
  recentHires: number;
  exitInterviews: number;
  pendingClaims: number;
  unreadMemos: number;
};

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    totalStaff: 0,
    totalDepartments: 0,
    activeEvaluations: 0,
    completedEvaluations: 0,
    pendingWarnings: 0,
    averageScore: 0,
    recentHires: 0,
    exitInterviews: 0,
    pendingClaims: 0,
    unreadMemos: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboardStats();
  }, []);

  const loadDashboardStats = async () => {
    try {
      const [
        staffCount,
        departmentsCount,
        evaluationsStats,
        recentHiresCount,
        exitInterviewsCount,
        claimsCount,
        memosCount
      ] = await Promise.all([
        getStaffCount(),
        getDepartmentsCount(),
        getEvaluationsStats(),
        getRecentHiresCount(),
        getExitInterviewsCount(),
        getPendingClaimsCount(),
        getUnreadMemosCount()
      ]);

      setStats({
        totalStaff: staffCount,
        totalDepartments: departmentsCount,
        activeEvaluations: evaluationsStats.active,
        completedEvaluations: evaluationsStats.completed,
        averageScore: evaluationsStats.averageScore,
        pendingWarnings: 0, // Removed warning letters count
        recentHires: recentHiresCount,
        exitInterviews: exitInterviewsCount,
        pendingClaims: claimsCount,
        unreadMemos: memosCount
      });
    } catch (error) {
      console.error('Error loading dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStaffCount = async () => {
    const { count } = await supabase
      .from('staff')
      .select('*', { count: 'exact', head: true });
    return count || 0;
  };

  const getDepartmentsCount = async () => {
    const { count } = await supabase
      .from('departments')
      .select('*', { count: 'exact', head: true });
    return count || 0;
  };

  const getEvaluationsStats = async () => {
    const { data } = await supabase
      .from('evaluation_responses')
      .select('status, percentage_score');

    const completed = data?.filter(e => e.status === 'completed') || [];
    const active = data?.filter(e => e.status === 'pending') || [];
    const scores = completed.map(e => e.percentage_score || 0);
    const averageScore = scores.length > 0 
      ? scores.reduce((a, b) => a + b, 0) / scores.length 
      : 0;

    return {
      active: active.length,
      completed: completed.length,
      averageScore
    };
  };

  const getRecentHiresCount = async () => {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const { count } = await supabase
      .from('staff')
      .select('*', { count: 'exact', head: true })
      .gte('join_date', thirtyDaysAgo.toISOString());
    return count || 0;
  };

  const getExitInterviewsCount = async () => {
    const { count } = await supabase
      .from('hr_letters')
      .select('*', { count: 'exact', head: true })
      .eq('type', 'interview')
      .eq('status', 'pending');
    return count || 0;
  };

  const getPendingClaimsCount = async () => {
    const { count } = await supabase
      .from('benefit_claims')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'pending');
    return count || 0;
  };

  const getUnreadMemosCount = async () => {
    const { count } = await supabase
      .from('memos')
      .select('*', { count: 'exact', head: true })
      .gte('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString());
    return count || 0;
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
      title: 'Staff',
      value: stats.totalStaff,
      icon: Users,
      color: 'blue',
      link: '/admin/staff/all'
    },
    {
      title: 'Departments',
      value: stats.totalDepartments,
      icon: Building2,
      color: 'indigo',
      link: '/admin/staff/departments'
    },
    {
      title: 'Recent Hires',
      value: stats.recentHires,
      icon: UserCircle,
      color: 'green',
      link: '/admin/staff/all'
    },
    {
      title: 'Exit Interviews',
      value: stats.exitInterviews,
      icon: FileText,
      color: 'red',
      link: '/admin/hr-form/exit-interview'
    }
  ];

  const actionCards = [
    {
      title: 'Active Reviews',
      value: stats.activeEvaluations,
      icon: FileText,
      color: 'purple',
      link: '/admin/evaluation/list/quarter'
    },
    {
      title: 'Pending Claims',
      value: stats.pendingClaims,
      icon: Gift,
      color: 'pink',
      link: '/admin/benefits/manage'
    },
    {
      title: 'Show Cause',
      value: stats.pendingWarnings,
      icon: AlertCircle,
      color: 'yellow',
      link: '/admin/misconduct/show-cause'
    },
    {
      title: 'New Memos',
      value: stats.unreadMemos,
      icon: Mail,
      color: 'cyan',
      link: '/admin/hr-form/memo'
    }
  ];

  const getColorClasses = (color: string) => {
    const colors = {
      blue: 'bg-blue-100 text-blue-600',
      indigo: 'bg-indigo-100 text-indigo-600',
      green: 'bg-green-100 text-green-600',
      red: 'bg-red-100 text-red-600',
      purple: 'bg-purple-100 text-purple-600',
      pink: 'bg-pink-100 text-pink-600',
      yellow: 'bg-yellow-100 text-yellow-600',
      cyan: 'bg-cyan-100 text-cyan-600'
    };
    return colors[color as keyof typeof colors] || colors.blue;
  };

  return (
    <div className="p-4 md:p-6 max-w-7xl mx-auto">
      <div className="mb-6">
        <h1 className="text-xl md:text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-xs md:text-sm text-gray-500">Overview of your organization's HR metrics</p>
      </div>

      {/* Organization Stats */}
      <div className="mb-6">
        <h2 className="text-sm font-medium text-gray-700 mb-3">Organization</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
          {statCards.map((stat) => (
            <Link 
              key={stat.title}
              to={stat.link}
              className="bg-white p-3 md:p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs md:text-sm text-gray-500">{stat.title}</p>
                  <p className="text-lg md:text-xl font-semibold mt-1">{stat.value}</p>
                </div>
                <div className={`p-2 rounded-lg ${getColorClasses(stat.color)}`}>
                  <stat.icon className="h-4 w-4 md:h-5 md:w-5" />
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>

      {/* Performance Overview */}
      <div className="mb-6">
        <h2 className="text-sm font-medium text-gray-700 mb-3">Performance</h2>
        <div className="bg-white rounded-lg shadow-sm p-3 md:p-4">
          <div className="grid grid-cols-3 gap-3 md:gap-4">
            <div className="bg-gray-50 p-2 md:p-3 rounded-lg">
              <p className="text-xs md:text-sm text-gray-500">Average Score</p>
              <p className="text-lg md:text-xl font-semibold mt-1">{stats.averageScore.toFixed(1)}%</p>
            </div>
            <div className="bg-gray-50 p-2 md:p-3 rounded-lg">
              <p className="text-xs md:text-sm text-gray-500">Active Reviews</p>
              <p className="text-lg md:text-xl font-semibold mt-1">{stats.activeEvaluations}</p>
            </div>
            <div className="bg-gray-50 p-2 md:p-3 rounded-lg">
              <p className="text-xs md:text-sm text-gray-500">Completed</p>
              <p className="text-lg md:text-xl font-semibold mt-1">{stats.completedEvaluations}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Action Items */}
      <div>
        <h2 className="text-sm font-medium text-gray-700 mb-3">Action Items</h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
          {actionCards.map((action) => (
            <Link 
              key={action.title}
              to={action.link}
              className="bg-white p-3 md:p-4 rounded-lg shadow-sm hover:shadow-md transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs md:text-sm text-gray-500">{action.title}</p>
                  <p className="text-lg md:text-xl font-semibold mt-1">{action.value}</p>
                </div>
                <div className={`p-2 rounded-lg ${getColorClasses(action.color)}`}>
                  <action.icon className="h-4 w-4 md:h-5 md:w-5" />
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}