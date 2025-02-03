import React from 'react';
import { X, Download } from 'lucide-react';
import { EmployeeFormResponse } from '../../../../types/employeeForm';
import { generateEmployeeFormPDF } from '../../../../utils/employeeFormPDF';
import { toast } from 'react-hot-toast';

type Props = {
  company: string;
  response: EmployeeFormResponse;
  onClose: () => void;
};

export default function ResponseViewer({ company, response, onClose }: Props) {
  const handleDownload = () => {
    try {
      generateEmployeeFormPDF(company, response);
      toast.success('Employee form downloaded successfully');
    } catch (error) {
      console.error('Error downloading form:', error);
      toast.error('Failed to download form');
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 z-[100] overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Employee Information</h2>
                <p className="mt-1 text-sm text-gray-500">
                  Submitted on {new Date(response.submitted_at).toLocaleString()}
                </p>
              </div>
              <div className="flex items-center space-x-4">
                <button
                  onClick={handleDownload}
                  className="text-indigo-600 hover:text-indigo-900 p-2 rounded-full hover:bg-indigo-50 transition-colors"
                  title="Download Form"
                >
                  <Download className="h-5 w-5" />
                </button>
                <button 
                  onClick={onClose}
                  className="text-gray-500 hover:text-gray-700"
                >
                  <X className="h-6 w-6" />
                </button>
              </div>
            </div>
          </div>

          <div className="p-6 space-y-8">
            {/* Personal Information */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h3>
              <dl className="grid grid-cols-2 gap-4">
                <div>
                  <dt className="text-sm font-medium text-gray-500">Full Name</dt>
                  <dd className="mt-1">{response.personal_info.fullName}</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-500">NRIC/Passport</dt>
                  <dd className="mt-1">{response.personal_info.nricPassport}</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-500">Date of Birth</dt>
                  <dd className="mt-1">{response.personal_info.dateOfBirth}</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-500">Gender</dt>
                  <dd className="mt-1">{response.personal_info.gender}</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-500">Nationality</dt>
                  <dd className="mt-1">{response.personal_info.nationality}</dd>
                </div>
                <div>
                  <dt className="text-sm font-medium text-gray-500">Phone</dt>
                  <dd className="mt-1">{response.personal_info.phone}</dd>
                </div>
                <div className="col-span-2">
                  <dt className="text-sm font-medium text-gray-500">Address</dt>
                  <dd className="mt-1">{response.personal_info.address}</dd>
                </div>
              </dl>
            </section>

            {/* Education History */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Education History</h3>
              <div className="space-y-4">
                {response.education_history.map((edu, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <dl className="grid grid-cols-2 gap-4">
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Institution</dt>
                        <dd className="mt-1">{edu.institution}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Qualification</dt>
                        <dd className="mt-1">{edu.qualification}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Field of Study</dt>
                        <dd className="mt-1">{edu.fieldOfStudy}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Graduation Year</dt>
                        <dd className="mt-1">{edu.graduationYear}</dd>
                      </div>
                    </dl>
                  </div>
                ))}
              </div>
            </section>

            {/* Employment History */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Employment History</h3>
              <div className="space-y-4">
                {response.employment_history.map((exp, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <dl className="grid grid-cols-2 gap-4">
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Company</dt>
                        <dd className="mt-1">{exp.company}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Position</dt>
                        <dd className="mt-1">{exp.position}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Start Date</dt>
                        <dd className="mt-1">{exp.startDate}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">End Date</dt>
                        <dd className="mt-1">{exp.endDate || 'Present'}</dd>
                      </div>
                      <div className="col-span-2">
                        <dt className="text-sm font-medium text-gray-500">Responsibilities</dt>
                        <dd className="mt-1">{exp.responsibilities}</dd>
                      </div>
                    </dl>
                  </div>
                ))}
              </div>
            </section>

            {/* Emergency Contacts */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Emergency Contacts</h3>
              <div className="space-y-4">
                {response.emergency_contacts.map((contact, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <dl className="grid grid-cols-2 gap-4">
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Name</dt>
                        <dd className="mt-1">{contact.name}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Relationship</dt>
                        <dd className="mt-1">{contact.relationship}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Phone</dt>
                        <dd className="mt-1">{contact.phone}</dd>
                      </div>
                      <div>
                        <dt className="text-sm font-medium text-gray-500">Address</dt>
                        <dd className="mt-1">{contact.address}</dd>
                      </div>
                    </dl>
                  </div>
                ))}
              </div>
            </section>
          </div>

          <div className="px-6 py-4 border-t border-gray-200">
            <div className="flex justify-end">
              <button
                onClick={onClose}
                className="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}