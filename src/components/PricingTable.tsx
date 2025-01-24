import React from 'react';
import { Check, Star } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from './ui/Button';

export default function PricingTable() {
  const features = [
    'Up to 50 employees',
    'KPI Management',
    'Performance Evaluations',
    'Company Benefits Management',
    'HR Letters & Documentation',
    'Achievement Tracking',
    'Staff Management',
    'Priority Support'
  ];

  return (
    <div id="pricing" className="bg-gradient-to-b from-gray-50 to-white py-16 md:py-24">
      <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold text-gray-900 mb-4">
            Simple, Transparent Pricing
          </h2>
          <p className="text-lg text-gray-600">
            Everything you need to manage your HR effectively
          </p>
        </div>

        <div className="relative">
          {/* Popular Badge */}
          <div className="absolute -top-4 left-1/2 -translate-x-1/2">
            <span className="inline-flex items-center px-4 py-1 rounded-full text-sm font-semibold bg-indigo-100 text-indigo-600">
              <Star className="w-4 h-4 mr-1" fill="currentColor" /> Most Popular
            </span>
          </div>

          {/* Pricing Card */}
          <div className="bg-white rounded-2xl p-8 md:p-10 shadow-xl border-2 border-indigo-100">
            <div className="text-center">
              <h3 className="text-2xl font-bold text-gray-900 mb-4">Professional Plan</h3>
              
              {/* Price */}
              <div className="flex items-baseline justify-center gap-x-2 mb-6">
                <span className="text-5xl font-bold text-indigo-600">RM50</span>
                <span className="text-xl text-gray-500">/month</span>
              </div>

              {/* Features List */}
              <div className="space-y-4 mb-8">
                {features.map((feature, index) => (
                  <div key={index} className="flex items-center justify-center text-gray-600">
                    <Check className="h-5 w-5 text-green-500 mr-2 flex-shrink-0" />
                    <span>{feature}</span>
                  </div>
                ))}
              </div>

              {/* CTA Button */}
              <Link to="/register">
                <Button 
                  variant="primary" 
                  className="w-full py-4 text-lg bg-indigo-600 hover:bg-indigo-700 transform hover:-translate-y-0.5 transition-all duration-200"
                >
                  Start Your Free Trial
                </Button>
              </Link>

              {/* Additional Info */}
              <div className="mt-6 space-y-2">
                <p className="text-sm text-gray-500">No credit card required</p>
                <div className="flex items-center justify-center space-x-2 text-xs text-gray-400">
                  <span>14-day free trial</span>
                  <span>•</span>
                  <span>Cancel anytime</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}