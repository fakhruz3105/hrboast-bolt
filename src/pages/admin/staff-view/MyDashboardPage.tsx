import React, { useState, useEffect } from 'react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
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
  Mail
} from 'lucide-react';
import { Link } from 'react-router-dom';
import ScoreDisplay from '../../../components/admin/evaluation/ScoreDisplay';
import { EvaluationResponse } from '../../../types/evaluation';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function MyDashboardPage() {
  const supabase = useSupabase();
  const { staff, loading } = useStaffProfile();
  const [evaluations, setEvaluations] = useState<EvaluationResponse[]>([]);
  const [benefits, setBenefits] = useState<any[]>([]);
  const [memos, setMemos] = useState<any[]>([]);
  const [loadingData, setLoadingData] = useState(true);

  useEffect(() => {
    if (staff?.id) {
      loadData(staff.id);
    }
  }, [staff?.id]);

  const loadData = async (staffId: string) => {
    try {
      const [evaluationsData, benefitsData, memosData] = await Promise.all([
        loadEvaluations(staffId),
        loadBenefits(staffId),
        loadMemos(staffId)
      ]);

      setEvaluations(evaluationsData || []);
      setBenefits(benefitsData || []);
      setMemos(memosData || []);
    } catch (error) {
      console.error('Error loading dashboard data:', error);
    } finally {
      setLoadingData(false);
    }
  };

  const loadEvaluations = async (staffId: string) => {
    const { data } = await supabase
      .from('evaluation_responses')
      .select(`
        *,
        evaluation:evaluation_id(title, type)
      `)
      .eq('staff_id', staffId)
      .order('created_at', { ascending: false });
    return data;
  };

  const loadBenefits = async (staffId: string) => {
    const { data } = await supabase.rpc('get_staff_eligible_benefits', {
      staff_uid: staffId
    });
    return data;
  };

  const loadMemos = async (staffId: string) => {
    const { data } = await supabase.rpc('get_staff_memo_list', {
      p_staff_id: staffId
    });
    return data;
  };

  if (loading || loadingData) {
    return (
      <div className="flex justify-center items-center min-h-screen p-4">
        <div className="animate-pulse text-gray-500">Loading dashboard...</div>
      </div>
    );
  }

  if (!staff) {
    return <div>Error loading profile</div>;
  }

  // Calculate years of service
  const joinDate = new Date(staff.join_date);
  const today = new Date();
  const yearsOfService = ((today.getTime() - joinDate.getTime()) / (1000 * 60 * 60 * 24 * 365.25)).toFixed(1);

  // Calculate average evaluation score
  const completedEvaluations = evaluations.filter(e => e.status === 'completed');
  const averageScore = completedEvaluations.length > 0
    ? completedEvaluations.reduce((sum, e) => sum + (e.percentage_score || 0), 0) / completedEvaluations.length
    : 0;

  // Get pending evaluations
  const pendingEvaluations = evaluations.filter(e => e.status === 'pending');

  const getPrimaryDepartment = () => {
    const primaryDept = staff.departments?.find(d => d.is_primary);
    return primaryDept?.department?.name || 'N/A';
  };

  const statCards = [
    {
      title: 'Average Score',
      value: `${averageScore.toFixed(1)}%`,
      icon: TrendingUp,
      color: 'green',
      link: '/admin/staff-view/evaluations'
    },
    {
      title: 'Pending Reviews',
      value: pendingEvaluations.length,
      icon: AlertCircle,
      color: 'yellow',
      link: '/admin/staff-view/evaluations'
    },
    {
      title: 'Available Benefits',
      value: benefits.filter(b => b.is_eligible).length,
      icon: Gift,
      color: 'purple',
      link: '/admin/staff-view/benefits'
    },
    {
      title: 'New Memos',
      value: memos.length,
      icon: Mail,
      color: 'blue',
      link: '/admin/staff-view/memo'
    }
  ];

  const getColorClasses = (color: string) => {
    const colors = {
      blue: 'bg-blue-100 text-blue-600',
      green: 'bg-green-100 text-green-600',
      yellow: 'bg-yellow-100 text-yellow-600',
      purple: 'bg-purple-100 text-purple-600'
    };
    return colors[color as keyof typeof colors] || colors.blue;
  };

  return (
    <div className="p-4 md:p-6 max-w-7xl mx-auto">
      {/* Profile Overview */}
      <div className="bg-white rounded-lg shadow-sm p-4 md:p-6 mb-6">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between">
          <div className="flex items-center mb-4 md:mb-0">
            <div className="bg-indigo-100 p-3 rounded-full">
              <UserCircle className="h-8 w-8 text-indigo-600" />
            </div>
            <div className="ml-4">
              <h2 className="text-lg font-semibold text-gray-900">{staff.name}</h2>
              <p className="text-sm text-gray-500">{staff.email}</p>
            </div>
          </div>
          <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
            staff.status === 'permanent' 
              ? 'bg-green-100 text-green-800'
              : staff.status === 'probation'
              ? 'bg-yellow-100 text-yellow-800'
              : 'bg-red-100 text-red-800'
          }`}>
            {staff.status.charAt(0).toUpperCase() + staff.status.slice(1)}
          </span>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
          <div className="flex items-center">
            <Building2 className="h-5 w-5 text-gray-400" />
            <div className="ml-3">
              <p className="text-xs text-gray-500">Department</p>
              <p className="text-sm font-medium">{getPrimaryDepartment()}</p>
            </div>
          </div>

          <div className="flex items-center">
            <UserCircle className="h-5 w-5 text-gray-400" />
            <div className="ml-3">
              <p className="text-xs text-gray-500">Position</p>
              <p className="text-sm font-medium">{staff.level?.name}</p>
            </div>
          </div>

          <div className="flex items-center">
            <Calendar className="h-5 w-5 text-gray-400" />
            <div className="ml-3">
              <p className="text-xs text-gray-500">Join Date</p>
              <p className="text-sm font-medium">{new Date(staff.join_date).toLocaleDateString()}</p>
            </div>
          </div>

          <div className="flex items-center">
            <Clock className="h-5 w-5 text-gray-400" />
            <div className="ml-3">
              <p className="text-xs text-gray-500">Years of Service</p>
              <p className="text-sm font-medium">{yearsOfService} years</p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-6">
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

      {/* Recent Evaluations */}
      <div className="bg-white rounded-lg shadow-sm">
        <div className="p-4 md:p-6">
          <h3 className="text-sm font-medium text-gray-900 mb-4">Recent Evaluations</h3>
          <div className="space-y-3">
            {evaluations.slice(0, 5).map((evaluation) => (
              <Link 
                key={evaluation.id}
                to="/admin/staff-view/evaluations"
                className="flex items-center justify-between p-3 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors"
              >
                <div>
                  <h4 className="text-sm font-medium text-gray-900">{evaluation.evaluation?.title}</h4>
                  <p className="text-xs text-gray-500 capitalize mt-1">{evaluation.evaluation?.type}</p>
                </div>
                <div className="flex items-center space-x-4">
                  {evaluation.percentage_score && (
                    <ScoreDisplay percentage={evaluation.percentage_score} />
                  )}
                  <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                    evaluation.status === 'completed'
                      ? 'bg-green-100 text-green-800'
                      : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {evaluation.status}
                  </span>
                </div>
              </Link>
            ))}
            {evaluations.length === 0 && (
              <div className="text-center py-6">
                <FileText className="h-8 w-8 text-gray-400 mx-auto mb-2" />
                <p className="text-sm text-gray-500">No evaluations found</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}