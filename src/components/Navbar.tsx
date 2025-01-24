import React, { useState } from 'react';
import { Menu, X, Briefcase } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from './ui/Button';

export default function Navbar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="bg-white shadow-lg fixed w-full z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex items-center">
              <Briefcase className="h-6 sm:h-8 w-6 sm:w-8 text-indigo-600" />
              <span className="ml-2 text-lg sm:text-xl font-bold text-gray-800">HR Boast</span>
            </Link>
          </div>
          
          <div className="hidden md:flex items-center space-x-8">
            <a href="/#features" className="text-gray-600 hover:text-indigo-600">Features</a>
            <a href="/#pricing" className="text-gray-600 hover:text-indigo-600">Pricing</a>
            <Link to="/login">
              <Button variant="primary">Login</Button>
            </Link>
          </div>

          <div className="md:hidden flex items-center">
            <button 
              onClick={() => setIsOpen(!isOpen)} 
              className="inline-flex items-center justify-center p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
            >
              {isOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </div>

      {isOpen && (
        <div className="md:hidden absolute w-full bg-white border-b border-gray-200">
          <div className="px-4 pt-2 pb-3 space-y-3">
            <a 
              href="/#features" 
              className="block px-3 py-2 text-base font-medium text-gray-600 hover:text-indigo-600 hover:bg-gray-50 rounded-md"
              onClick={() => setIsOpen(false)}
            >
              Features
            </a>
            <a 
              href="/#pricing" 
              className="block px-3 py-2 text-base font-medium text-gray-600 hover:text-indigo-600 hover:bg-gray-50 rounded-md"
              onClick={() => setIsOpen(false)}
            >
              Pricing
            </a>
            <Link 
              to="/login" 
              className="block px-3 py-2"
              onClick={() => setIsOpen(false)}
            >
              <Button variant="primary" className="w-full justify-center">Login</Button>
            </Link>
          </div>
        </div>
      )}
    </nav>
  );
}