import React from 'react';

type ButtonProps = {
  variant?: 'primary' | 'secondary';
  children: React.ReactNode;
  href?: string;
  className?: string;
};

export function Button({ variant = 'primary', children, href, className = '' }: ButtonProps) {
  const baseStyles = "inline-flex items-center px-6 py-3 rounded-lg font-medium transition-all duration-200";
  const variants = {
    primary: "bg-indigo-600 text-white hover:bg-indigo-700 shadow-lg hover:shadow-xl",
    secondary: "bg-white text-indigo-600 border-2 border-indigo-600 hover:bg-indigo-50"
  };

  const classes = `${baseStyles} ${variants[variant]} ${className}`;

  return href ? (
    <a href={href} className={classes}>{children}</a>
  ) : (
    <button className={classes}>{children}</button>
  );
}