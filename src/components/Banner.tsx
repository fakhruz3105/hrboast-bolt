import React from 'react';
import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from './ui/Button';

export default function Banner() {
  return (
    <div id="home" className="relative min-h-[70vh] flex items-center justify-center overflow-hidden">
      {/* Background Image with mobile optimization */}
      <div className="absolute inset-0">
        <img 
          src="https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&q=80"
          alt="Modern Office"
          className="w-full h-full object-cover"
          loading="eager"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-black/70 to-black/50"></div>
      </div>

      {/* Content */}
      <div className="relative w-full max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 md:py-16 text-center">
        <h1 className="text-3xl sm:text-4xl md:text-6xl font-bold text-white tracking-tight mb-4 sm:mb-6 leading-tight">
          Boast your HR management
        </h1>
        <div className="max-w-3xl mx-auto">
          <p className="text-lg sm:text-xl md:text-3xl text-white/90 mb-8 sm:mb-12 leading-relaxed">
            All systems focus on payroll, we focus on empowering your HR management
          </p>
        </div>
        <Link to="/register">
          <Button 
            variant="primary"
            className="bg-indigo-600 text-white hover:bg-indigo-700 shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 transition-all duration-200 text-base sm:text-lg px-6 sm:px-8 py-3 sm:py-4 rounded-xl w-full sm:w-auto"
          >
            Start Free Trial <ArrowRight className="ml-2 h-5 w-5" />
          </Button>
        </Link>
      </div>
    </div>
  );
}