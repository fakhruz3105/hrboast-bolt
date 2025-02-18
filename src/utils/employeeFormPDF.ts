import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';
import { EmployeeFormResponse } from '../types/employeeForm';

export function generateEmployeeFormPDF(companyName: string, response: EmployeeFormResponse) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(companyName, doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/EMP', y);
    y = PDFHelpers.addDate(doc, response.submitted_at, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Form Title
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Personal Information
    y = PDFHelpers.addSectionHeading(doc, 'Personal Information', y);
    y = PDFHelpers.addWrappedText(doc, `Full Name: ${response.personal_info.fullName}`, y);
    y = PDFHelpers.addWrappedText(doc, `NRIC/Passport: ${response.personal_info.nricPassport}`, y);
    y = PDFHelpers.addWrappedText(doc, `Date of Birth: ${response.personal_info.dateOfBirth}`, y);
    y = PDFHelpers.addWrappedText(doc, `Gender: ${response.personal_info.gender}`, y);
    y = PDFHelpers.addWrappedText(doc, `Nationality: ${response.personal_info.nationality}`, y);
    y = PDFHelpers.addWrappedText(doc, `Phone: ${response.personal_info.phone}`, y);
    y = PDFHelpers.addWrappedText(doc, `Email: ${response.personal_info.email}`, y);
    y = PDFHelpers.addWrappedText(doc, `Address: ${response.personal_info.address}`, y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Education History
    y = PDFHelpers.addSectionHeading(doc, 'Education History', y);
    response.education_history.forEach((edu, index) => {
      y = PDFHelpers.addWrappedText(doc, `Education ${index + 1}:`, y);
      y = PDFHelpers.addWrappedText(doc, `Institution: ${edu.institution}`, y);
      y = PDFHelpers.addWrappedText(doc, `Qualification: ${edu.qualification}`, y);
      y = PDFHelpers.addWrappedText(doc, `Field of Study: ${edu.fieldOfStudy}`, y);
      y = PDFHelpers.addWrappedText(doc, `Graduation Year: ${edu.graduationYear}`, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    });
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Employment History
    y = PDFHelpers.addSectionHeading(doc, 'Employment History', y);
    response.employment_history.forEach((exp, index) => {
      y = PDFHelpers.addWrappedText(doc, `Experience ${index + 1}:`, y);
      y = PDFHelpers.addWrappedText(doc, `Company: ${exp.company}`, y);
      y = PDFHelpers.addWrappedText(doc, `Position: ${exp.position}`, y);
      y = PDFHelpers.addWrappedText(doc, `Start Date: ${exp.startDate}`, y);
      y = PDFHelpers.addWrappedText(doc, `End Date: ${exp.endDate || 'Present'}`, y);
      y = PDFHelpers.addWrappedText(doc, `Responsibilities: ${exp.responsibilities}`, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    });
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Emergency Contacts
    y = PDFHelpers.addSectionHeading(doc, 'Emergency Contacts', y);
    response.emergency_contacts.forEach((contact, index) => {
      y = PDFHelpers.addWrappedText(doc, `Contact ${index + 1}:`, y);
      y = PDFHelpers.addWrappedText(doc, `Name: ${contact.name}`, y);
      y = PDFHelpers.addWrappedText(doc, `Relationship: ${contact.relationship}`, y);
      y = PDFHelpers.addWrappedText(doc, `Phone: ${contact.phone}`, y);
      y = PDFHelpers.addWrappedText(doc, `Address: ${contact.address}`, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    });

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    doc.save(`employee-form-${response.personal_info.fullName.replace(/\s+/g, '-').toLowerCase()}.pdf`);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate employee form PDF');
  }
}