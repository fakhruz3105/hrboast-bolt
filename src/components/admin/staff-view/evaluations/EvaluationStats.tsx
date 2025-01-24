import React from 'react';
import { EvaluationResponse } from '../../../../types/evaluation';
import { TrendingUp, Clock, CheckCircle } from 'lucide-react';

type Props = {
  evaluations: EvaluationResponse[];
};

export default function EvaluationStats({ evaluations }: Props) {
  const completedEvaluations = evaluations.filter(e => e.status === 'completed');
  const averageScore = completedEvaluations.length > 0
    ? completedEvaluations.reduce((sum, e) => sum + (e.percentage_score || 0), 0) / completedEvaluations.length
    : 0;

  const stats = [
    {
      name: 'Average Score',
      value: `${averageScore.toFixed(1)}%`,
      icon: TrendingUp,
      color: 'text-green-600',
      bgColor: 'bg-green-100'
    },
    {
      name: 'Completed',
      value: completedEvaluations.length,
      icon: CheckCircle,
      color: 'text-blue-600',
      bgColor: 'bg-blue-100'
    },
    {
      name: 'Pending',
      value: evaluations.length - completedEvaluations.length,
      icon: Clock,
      color: 'text-yellow-600',
      bgColor: 'bg-yellow-100'
    }
  ];

  return (
    <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
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