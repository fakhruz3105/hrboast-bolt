import React from 'react';
import { Target, CheckCircle, Clock, AlertTriangle } from 'lucide-react';

type Props = {
  kpis: any[];
};

export default function KPIStats({ kpis }: Props) {
  // Calculate statistics
  const totalKPIs = kpis.length;
  const achievedKPIs = kpis.filter(kpi => kpi.status === 'Achieved').length;
  const pendingKPIs = kpis.filter(kpi => kpi.status === 'Pending').length;
  const notAchievedKPIs = kpis.filter(kpi => kpi.status === 'Not Achieved').length;
  
  const achievementRate = totalKPIs > 0 ? (achievedKPIs / totalKPIs) * 100 : 0;

  const stats = [
    {
      name: 'Achievement Rate',
      value: `${achievementRate.toFixed(1)}%`,
      icon: Target,
      color: 'text-indigo-600',
      bgColor: 'bg-indigo-100'
    },
    {
      name: 'Achieved',
      value: achievedKPIs,
      icon: CheckCircle,
      color: 'text-green-600',
      bgColor: 'bg-green-100'
    },
    {
      name: 'Pending',
      value: pendingKPIs,
      icon: Clock,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100'
    },
    {
      name: 'Not Achieved',
      value: notAchievedKPIs,
      icon: AlertTriangle,
      color: 'text-red-600',
      bgColor: 'bg-red-100'
    }
  ];

  return (
    <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
      {stats.map((stat) => (
        <div key={stat.name} className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className={`flex-shrink-0 ${stat.bgColor} rounded-md p-3`}>
                <stat.icon className={`h-6 w-6 ${stat.color}`} />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    {stat.name}
                  </dt>
                  <dd className="text-lg font-semibold text-gray-900">
                    {stat.value}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}