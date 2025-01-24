import React from 'react';
import { Building2 } from 'lucide-react';

export default function TrustedBy() {
  const companies = [
    { name: 'TechCorp', icon: Building2 },
    { name: 'InnovateLabs', icon: Building2 },
    { name: 'FutureWorks', icon: Building2 },
    { name: 'GlobalTech', icon: Building2 },
    { name: 'SmartSolutions', icon: Building2 }
  ];

  return (
    <div className="bg-gray-50 py-16">
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
        <p className="text-center text-gray-600 text-sm font-medium mb-8">TRUSTED BY INNOVATIVE COMPANIES</p>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-8 items-center justify-items-center">
          {companies.map((company, index) => (
            <div key={index} className="flex items-center space-x-2 text-gray-400 hover:text-gray-600 transition-colors">
              <company.icon className="h-6 w-6" />
              <span className="font-semibold">{company.name}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}