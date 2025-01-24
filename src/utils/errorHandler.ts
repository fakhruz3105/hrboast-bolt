import { toast } from 'react-hot-toast';

export type ErrorType = 
  | 'DEPARTMENT_HAS_STAFF'
  | 'INVALID_FORM'
  | 'UNAUTHORIZED'
  | 'DATABASE_ERROR'
  | 'NETWORK_ERROR'
  | 'VALIDATION_ERROR';

export const ErrorMessages: Record<ErrorType, string> = {
  DEPARTMENT_HAS_STAFF: 'Cannot delete department that has staff members assigned to it',
  INVALID_FORM: 'Please fill in all required fields correctly',
  UNAUTHORIZED: 'You do not have permission to perform this action',
  DATABASE_ERROR: 'A database error occurred. Please try again later',
  NETWORK_ERROR: 'Network error. Please check your connection',
  VALIDATION_ERROR: 'Please check your input and try again'
};

export function handleError(error: any) {
  console.error('Error:', error);

  // Extract error message
  const message = error?.message || 'An unexpected error occurred';

  // Check for specific error types
  if (message.includes('has staff members')) {
    toast.error(ErrorMessages.DEPARTMENT_HAS_STAFF);
    return;
  }

  if (message.includes('permission')) {
    toast.error(ErrorMessages.UNAUTHORIZED);
    return;
  }

  if (message.includes('validation')) {
    toast.error(ErrorMessages.VALIDATION_ERROR);
    return;
  }

  // Default error message
  toast.error(message);
}

export function validateForm(data: any, rules: Record<string, (value: any) => boolean>) {
  const errors: Record<string, string> = {};

  Object.entries(rules).forEach(([field, validator]) => {
    if (!validator(data[field])) {
      errors[field] = `Invalid ${field.replace('_', ' ')}`;
    }
  });

  return errors;
}