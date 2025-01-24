import { jsPDF } from 'jspdf';
import { StaffInterviewForm } from '../types/staffInterview';

export function generatePDF(response: StaffInterviewForm) {
  const doc = new jsPDF();
  const margin = 20;
  let y = margin;
  const lineHeight = 7;
  const pageWidth = doc.internal.pageSize.width;

  // Helper functions
  const addTitle = (text: string) => {
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(14);
    doc.text(text, margin, y);
    y += lineHeight * 1.5;
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(10);
  };

  const addField = (label: string, value: string) => {
    const labelWidth = doc.getTextWidth(label + ': ');
    const maxValueWidth = pageWidth - margin * 2 - labelWidth;
    
    doc.setFont('helvetica', 'bold');
    doc.text(label + ': ', margin, y);
    doc.setFont('helvetica', 'normal');
    
    const lines = doc.splitTextToSize(value || '-', maxValueWidth);
    doc.text(lines, margin + labelWidth, y);
    y += lineHeight * lines.length;
  };

  const checkPageBreak = (neededSpace: number) => {
    if (y + neededSpace > doc.internal.pageSize.height - margin) {
      doc.addPage();
      y = margin;
    }
  };

  // Title
  doc.setFontSize(16);
  doc.setFont('helvetica', 'bold');
  doc.text('Interview Form Response', margin, y);
  y += lineHeight * 2;

  // Personal Information
  checkPageBreak(lineHeight * 10);
  addTitle('Personal Information');
  addField('Full Name', response.personal_info.fullName);
  addField('NRIC/Passport', response.personal_info.nricPassport);
  addField('Date of Birth', response.personal_info.dateOfBirth);
  addField('Gender', response.personal_info.gender);
  addField('Nationality', response.personal_info.nationality);
  addField('Phone', response.personal_info.phone);
  addField('Address', response.personal_info.address);
  y += lineHeight;

  // Education History
  checkPageBreak(lineHeight * 4);
  addTitle('Education History');
  response.education_history.forEach((edu, index) => {
    checkPageBreak(lineHeight * 6);
    doc.setFont('helvetica', 'bold');
    doc.text(`Education ${index + 1}`, margin, y);
    y += lineHeight;
    doc.setFont('helvetica', 'normal');
    addField('Institution', edu.institution);
    addField('Qualification', edu.qualification);
    addField('Field of Study', edu.fieldOfStudy);
    addField('Graduation Year', edu.graduationYear);
    y += lineHeight;
  });

  // Work Experience
  checkPageBreak(lineHeight * 4);
  addTitle('Work Experience');
  response.work_experience.forEach((exp, index) => {
    checkPageBreak(lineHeight * 8);
    doc.setFont('helvetica', 'bold');
    doc.text(`Experience ${index + 1}`, margin, y);
    y += lineHeight;
    doc.setFont('helvetica', 'normal');
    addField('Company', exp.company);
    addField('Position', exp.position);
    addField('Start Date', exp.startDate);
    addField('End Date', exp.endDate || 'Present');
    addField('Responsibilities', exp.responsibilities);
    y += lineHeight;
  });

  // Emergency Contacts
  checkPageBreak(lineHeight * 4);
  addTitle('Emergency Contacts');
  response.emergency_contacts.forEach((contact, index) => {
    checkPageBreak(lineHeight * 6);
    doc.setFont('helvetica', 'bold');
    doc.text(`Contact ${index + 1}`, margin, y);
    y += lineHeight;
    doc.setFont('helvetica', 'normal');
    addField('Name', contact.name);
    addField('Relationship', contact.relationship);
    addField('Phone', contact.phone);
    addField('Address', contact.address);
    y += lineHeight;
  });

  // Save the PDF
  doc.save(`interview-form-${response.personal_info.fullName.replace(/\s+/g, '-')}.pdf`);
}