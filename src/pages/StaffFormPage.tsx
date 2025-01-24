import React from 'react';
import { useParams } from 'react-router-dom';
import EmployeeForm from '../components/staff/EmployeeForm';

export default function StaffFormPage() {
  const { formId } = useParams();

  if (!formId) {
    return <div>Invalid form link</div>;
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-3xl mx-auto">
        <div className="bg-white shadow rounded-lg p-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">Employee Information Form</h1>
          <EmployeeForm formId={formId} />
        </div>
      </div>
    </div>
  );
}