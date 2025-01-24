import React, { useState } from 'react';
import { supabase } from '../../lib/supabase';

type Props = {
  formRequest: any;
};

export default function EmployeeForm({ formRequest }: Props) {
  const [formData, setFormData] = useState({
    personal_info: {
      fullName: formRequest.staff_name,
      nricPassport: '',
      dateOfBirth: '',
      gender: '',
      nationality: '',
      address: '',
      phone: formRequest.phone_number,
      email: formRequest.email
    },
    education_history: [{
      institution: '',
      qualification: '',
      fieldOfStudy: '',
      graduationYear: ''
    }],
    employment_history: [{
      company: '',
      position: '',
      startDate: '',
      endDate: '',
      responsibilities: ''
    }],
    emergency_contacts: [{
      name: '',
      relationship: '',
      phone: '',
      address: ''
    }]
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      // Submit form response
      const { error: responseError } = await supabase
        .from('employee_form_responses')
        .insert([{
          request_id: formRequest.id,
          ...formData
        }]);

      if (responseError) throw responseError;

      // Update request status
      const { error: statusError } = await supabase
        .from('employee_form_requests')
        .update({ status: 'completed' })
        .eq('id', formRequest.id);

      if (statusError) throw statusError;

      window.location.href = '/thank-you';
    } catch (error) {
      console.error('Error submitting form:', error);
      alert('Failed to submit form. Please try again.');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      {/* Personal Information */}
      <section>
        <h3 className="text-lg font-medium text-gray-900 mb-4">Personal Information</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700">Full Name</label>
            <input
              type="text"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.fullName}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, fullName: e.target.value }
              })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">NRIC/Passport</label>
            <input
              type="text"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.nricPassport}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, nricPassport: e.target.value }
              })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Date of Birth</label>
            <input
              type="date"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.dateOfBirth}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, dateOfBirth: e.target.value }
              })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Gender</label>
            <select
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.gender}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, gender: e.target.value }
              })}
            >
              <option value="">Select Gender</option>
              <option value="male">Male</option>
              <option value="female">Female</option>
              <option value="other">Other</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Nationality</label>
            <input
              type="text"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.nationality}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, nationality: e.target.value }
              })}
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700">Phone</label>
            <input
              type="tel"
              required
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.phone}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, phone: e.target.value }
              })}
            />
          </div>
          <div className="md:col-span-2">
            <label className="block text-sm font-medium text-gray-700">Address</label>
            <textarea
              required
              rows={3}
              className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
              value={formData.personal_info.address}
              onChange={(e) => setFormData({
                ...formData,
                personal_info: { ...formData.personal_info, address: e.target.value }
              })}
            />
          </div>
        </div>
      </section>

      {/* Education History */}
      <section>
        <h3 className="text-lg font-medium text-gray-900 mb-4">Education History</h3>
        {formData.education_history.map((edu, index) => (
          <div key={index} className="mb-4 p-4 border border-gray-200 rounded-lg">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Institution</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={edu.institution}
                  onChange={(e) => {
                    const newHistory = [...formData.education_history];
                    newHistory[index].institution = e.target.value;
                    setFormData({ ...formData, education_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Qualification</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={edu.qualification}
                  onChange={(e) => {
                    const newHistory = [...formData.education_history];
                    newHistory[index].qualification = e.target.value;
                    setFormData({ ...formData, education_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Field of Study</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={edu.fieldOfStudy}
                  onChange={(e) => {
                    const newHistory = [...formData.education_history];
                    newHistory[index].fieldOfStudy = e.target.value;
                    setFormData({ ...formData, education_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Graduation Year</label>
                <input
                  type="number"
                  required
                  min="1950"
                  max={new Date().getFullYear()}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={edu.graduationYear}
                  onChange={(e) => {
                    const newHistory = [...formData.education_history];
                    newHistory[index].graduationYear = e.target.value;
                    setFormData({ ...formData, education_history: newHistory });
                  }}
                />
              </div>
            </div>
          </div>
        ))}
        <button
          type="button"
          onClick={() => setFormData({
            ...formData,
            education_history: [...formData.education_history, {
              institution: '',
              qualification: '',
              fieldOfStudy: '',
              graduationYear: ''
            }]
          })}
          className="text-sm text-indigo-600 hover:text-indigo-900"
        >
          Add Education
        </button>
      </section>

      {/* Employment History */}
      <section>
        <h3 className="text-lg font-medium text-gray-900 mb-4">Employment History</h3>
        {formData.employment_history.map((exp, index) => (
          <div key={index} className="mb-4 p-4 border border-gray-200 rounded-lg">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Company</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={exp.company}
                  onChange={(e) => {
                    const newHistory = [...formData.employment_history];
                    newHistory[index].company = e.target.value;
                    setFormData({ ...formData, employment_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Position</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={exp.position}
                  onChange={(e) => {
                    const newHistory = [...formData.employment_history];
                    newHistory[index].position = e.target.value;
                    setFormData({ ...formData, employment_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Start Date</label>
                <input
                  type="date"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={exp.startDate}
                  onChange={(e) => {
                    const newHistory = [...formData.employment_history];
                    newHistory[index].startDate = e.target.value;
                    setFormData({ ...formData, employment_history: newHistory });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">End Date</label>
                <input
                  type="date"
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={exp.endDate}
                  onChange={(e) => {
                    const newHistory = [...formData.employment_history];
                    newHistory[index].endDate = e.target.value;
                    setFormData({ ...formData, employment_history: newHistory });
                  }}
                />
              </div>
              <div className="md:col-span-2">
                <label className="block text-sm font-medium text-gray-700">Responsibilities</label>
                <textarea
                  required
                  rows={3}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={exp.responsibilities}
                  onChange={(e) => {
                    const newHistory = [...formData.employment_history];
                    newHistory[index].responsibilities = e.target.value;
                    setFormData({ ...formData, employment_history: newHistory });
                  }}
                />
              </div>
            </div>
          </div>
        ))}
        <button
          type="button"
          onClick={() => setFormData({
            ...formData,
            employment_history: [...formData.employment_history, {
              company: '',
              position: '',
              startDate: '',
              endDate: '',
              responsibilities: ''
            }]
          })}
          className="text-sm text-indigo-600 hover:text-indigo-900"
        >
          Add Employment
        </button>
      </section>

      {/* Emergency Contacts */}
      <section>
        <h3 className="text-lg font-medium text-gray-900 mb-4">Emergency Contacts</h3>
        {formData.emergency_contacts.map((contact, index) => (
          <div key={index} className="mb-4 p-4 border border-gray-200 rounded-lg">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Name</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={contact.name}
                  onChange={(e) => {
                    const newContacts = [...formData.emergency_contacts];
                    newContacts[index].name = e.target.value;
                    setFormData({ ...formData, emergency_contacts: newContacts });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Relationship</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={contact.relationship}
                  onChange={(e) => {
                    const newContacts = [...formData.emergency_contacts];
                    newContacts[index].relationship = e.target.value;
                    setFormData({ ...formData, emergency_contacts: newContacts });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Phone</label>
                <input
                  type="tel"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={contact.phone}
                  onChange={(e) => {
                    const newContacts = [...formData.emergency_contacts];
                    newContacts[index].phone = e.target.value;
                    setFormData({ ...formData, emergency_contacts: newContacts });
                  }}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Address</label>
                <textarea
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={contact.address}
                  onChange={(e) => {
                    const newContacts = [...formData.emergency_contacts];
                    newContacts[index].address = e.target.value;
                    setFormData({ ...formData, emergency_contacts: newContacts });
                  }}
                />
              </div>
            </div>
          </div>
        ))}
        <button
          type="button"
          onClick={() => setFormData({
            ...formData,
            emergency_contacts: [...formData.emergency_contacts, {
              name: '',
              relationship: '',
              phone: '',
              address: ''
            }]
          })}
          className="text-sm text-indigo-600 hover:text-indigo-900"
        >
          Add Emergency Contact
        </button>
      </section>

      <div className="flex justify-end">
        <button
          type="submit"
          className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          Submit Form
        </button>
      </div>
    </form>
  );
}