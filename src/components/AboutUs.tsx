import React from 'react';
import { Target, Users, Shield, Award, FileText, Gift } from 'lucide-react';

export default function AboutUs() {
  return (
    <div id="features" className="bg-white py-12 md:py-16">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-8 md:mb-12">
          <h2 className="text-2xl md:text-3xl font-bold text-gray-900 mb-3">Comprehensive HR Solutions</h2>
          <p className="text-gray-600 max-w-2xl mx-auto text-sm md:text-base">
            Everything you need to manage your workforce effectively in one platform
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          {[
            {
              icon: Target,
              title: "KPI Module",
              description: "Set, track, and evaluate key performance indicators"
            },
            {
              icon: FileText,
              title: "Evaluation Module",
              description: "Comprehensive employee performance evaluations"
            },
            {
              icon: Gift,
              title: "Company Benefits",
              description: "Manage and track employee benefits and claims"
            },
            {
              icon: Shield,
              title: "HR Letters",
              description: "Handle misconduct, exit interviews, and official documentation"
            },
            {
              icon: Award,
              title: "Achievement Tracking",
              description: "Record and celebrate employee achievements"
            },
            {
              icon: Users,
              title: "Staff Management",
              description: "Efficient employee data and department management"
            }
          ].map((item, index) => (
            <div key={index} className="bg-white p-4 sm:p-6 rounded-xl border border-gray-100 hover:border-indigo-100 hover:shadow-md transition-all">
              <div className="bg-indigo-100 rounded-full p-3 w-12 h-12 flex items-center justify-center mb-4">
                <item.icon className="h-6 w-6 text-indigo-600" />
              </div>
              <h3 className="text-base sm:text-lg font-semibold mb-2">{item.title}</h3>
              <p className="text-gray-600 text-sm">
                {item.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}