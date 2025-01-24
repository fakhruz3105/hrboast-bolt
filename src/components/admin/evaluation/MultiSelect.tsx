import React, { useState, useRef, useEffect } from 'react';
import { Check, ChevronDown } from 'lucide-react';

type Props = {
  options: any[];
  value: string[];
  onChange: (value: string[]) => void;
  displayKey: string;
  valueKey: string;
  placeholder?: string;
};

export default function MultiSelect({ options, value, onChange, displayKey, valueKey, placeholder }: Props) {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const toggleOption = (optionValue: string) => {
    const newValue = value.includes(optionValue)
      ? value.filter(v => v !== optionValue)
      : [...value, optionValue];
    onChange(newValue);
  };

  const getSelectedLabels = () => {
    return value
      .map(v => options.find(opt => opt[valueKey] === v)?.[displayKey])
      .filter(Boolean)
      .join(', ');
  };

  return (
    <div className="relative" ref={containerRef}>
      <div
        className="mt-1 relative"
        onClick={() => setIsOpen(!isOpen)}
      >
        <button
          type="button"
          className="relative w-full bg-white border border-gray-300 rounded-md shadow-sm pl-3 pr-10 py-2 text-left cursor-default focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500"
        >
          <span className="block truncate">
            {value.length > 0 ? getSelectedLabels() : placeholder || 'Select options'}
          </span>
          <span className="absolute inset-y-0 right-0 flex items-center pr-2 pointer-events-none">
            <ChevronDown className="h-5 w-5 text-gray-400" />
          </span>
        </button>
      </div>

      {isOpen && (
        <div className="absolute z-10 mt-1 w-full bg-white shadow-lg max-h-60 rounded-md py-1 text-base overflow-auto focus:outline-none sm:text-sm">
          {options.map((option) => (
            <div
              key={option[valueKey]}
              className={`
                cursor-pointer select-none relative py-2 pl-3 pr-9 hover:bg-indigo-50
                ${value.includes(option[valueKey]) ? 'bg-indigo-50' : ''}
              `}
              onClick={() => toggleOption(option[valueKey])}
            >
              <span className="block truncate">
                {option[displayKey]}
              </span>
              {value.includes(option[valueKey]) && (
                <span className="absolute inset-y-0 right-0 flex items-center pr-4">
                  <Check className="h-5 w-5 text-indigo-600" />
                </span>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}