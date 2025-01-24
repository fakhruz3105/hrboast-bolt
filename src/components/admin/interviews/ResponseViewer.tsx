import React from 'react';
import { X } from 'lucide-react';

type FormResponse = {
  personal_info: {
    fullName: string;
    nricPassport: string;
    dateOfBirth: string;
    gender: string;
    nationality: string;
    address: string;
    phone: string;
    email: string;
  };
  education_history: Array<{
    institution: string;
    qualification: string;
    fieldOfStudy: string;
    graduationYear: string;
  }>;
  work_experience: Array<{
    company: string;
    position: string;
    startDate: string;
    endDate: string;
    responsibilities: string;
  }>;
  emergency_contacts: Array<{
    name: string;
    relationship: string;
    phone: string;
    address: string;
  }>;
};

type Props = {
  response: FormResponse;
  onClose: () => void;
};

export default function ResponseViewer({ response, onClose }: Props) {
  return (
    <div className="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
      <div className="min-h-screen px-4 py-8">
        <div className="relative bg-white max-w-4xl mx-auto rounded-xl shadow-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <div className="flex justify-between items-center">
              <h2 className="text-2xl font-bold text-gray-900">Employee Information</h2>
              <button 
                onClick={onClose}
                className="text-gray-500 hover:text-gray-700"
              >
                <X className="h-6 w-6" />
              </button>
            </div>
          </div>

          <div className="p-6 space-y-8">
            {/* Personal Information */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Personal Information</h3>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-500">Full Name</label>
                  <p className="mt-1">{response.personal_info.fullName}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">NRIC/Passport</label>
                  <p className="mt-1">{response.personal_info.nricPassport}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Date of Birth</label>
                  <p className="mt-1">{response.personal_info.dateOfBirth}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Gender</label>
                  <p className="mt-1">{response.personal_info.gender}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Nationality</label>
                  <p className="mt-1">{response.personal_info.nationality}</p>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-500">Phone</label>
                  <p className="mt-1">{response.personal_info.phone}</p>
                </div>
                <div className="col-span-2">
                  <label className="block text-sm font-medium text-gray-500">Address</label>
                  <p className="mt-1">{response.personal_info.address}</p>
                </div>
              </div>
            </section>

            {/* Education History */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Education History</h3>
              <div className="space-y-4">
                {response.education_history.map((edu, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Institution</label>
                        <p className="mt-1">{edu.institution}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Qualification</label>
                        <p className="mt-1">{edu.qualification}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Field of Study</label>
                        <p className="mt-1">{edu.fieldOfStudy}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Graduation Year</label>
                        <p className="mt-1">{edu.graduationYear}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </section>

            {/* Work Experience */}
            <section>
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Work Experience</h3>
              <div className="space-y-4">
                {response.work_experience.map((exp, index) => (
                  <div key={index} className="bg-gray-50 p-4 rounded-lg">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Company</label>
                        <p className="mt-1">{exp.company}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Position</label>
                        <p className="mt-1">{exp.position}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Start Date</label>
                        <p className="mt-1">{exp.startDate}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">End Date</label>
                        <p className="mt-1">{exp.endDate || 'Present'}</p>
                      </div>
                      <div className="col-span-2">
                        <label className="block text-sm font-medium text-gray-500">Responsibilities</label>
                        <p className="mt-1">{exp.responsibilities}</p>
                      </div>
                    </div>
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
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Name</label>
                        <p className="mt-1">{contact.name}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Relationship</label>
                        <p className="mt-1">{contact.relationship}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Phone</label>
                        <p className="mt-1">{contact.phone}</p>
                      </div>
                      <div>
                        <label className="block text-sm font-medium text-gray-500">Address</label>
                        <p className="mt-1">{contact.address}</p>
                      </div>
                    </div>
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