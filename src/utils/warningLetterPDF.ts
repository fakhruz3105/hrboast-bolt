import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';

type WarningLetter = {
  staff: {
    name: string;
    departments?: Array<{
      is_primary: boolean;
      department: {
        name: string;
      };
    }>;
  };
  content: {
    warning_level?: string;
    incident_date?: string;
    description?: string;
    improvement_plan?: string;
    consequences?: string;
  };
  issued_date: string;
};

export function generateWarningLetterPDF(companyName: string, letter: WarningLetter) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(companyName, doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/WL', y);
    y = PDFHelpers.addDate(doc, letter.issued_date, y);

    // Letter Title
    const title = (letter.content.warning_level || '').toUpperCase() + ' WARNING LETTER';
    y = PDFHelpers.addTitle(doc, title, y);

    // Add salutation
    y = PDFHelpers.addSalutation(doc, y);

    // Staff Details
    const department = letter.staff.departments?.find(d => d.is_primary)?.department?.name || 'N/A';
    
    // Name on first line
    y = PDFHelpers.addWrappedText(doc, 'Name: ' + letter.staff.name, y, true);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    
    // Department on second line
    y = PDFHelpers.addWrappedText(doc, 'Department: ' + department, y, true);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    
    // Incident date on third line
    if (letter.content.incident_date) {
      y = PDFHelpers.addWrappedText(doc, 'Incident Date: ' + new Date(letter.content.incident_date).toLocaleDateString(), y, true);
      y += PDF_CONSTANTS.LINE_HEIGHT * 2;
    }

    if (letter.content.description) {
      y = PDFHelpers.addSectionHeading(doc, 'Description:', y);
      y = PDFHelpers.addWrappedText(doc, letter.content.description, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (letter.content.improvement_plan) {
      y = PDFHelpers.addSectionHeading(doc, 'Required Improvements:', y);
      y = PDFHelpers.addWrappedText(doc, letter.content.improvement_plan, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (letter.content.consequences) {
      y = PDFHelpers.addSectionHeading(doc, 'Consequences:', y);
      y = PDFHelpers.addWrappedText(doc, letter.content.consequences, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    // Signatures
    y = PDFHelpers.addSignatureSection(doc, y, 'CEO', letter.staff.name, department);

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    const filename = 'warning-letter-' + letter.staff.name.toLowerCase().replace(/\s+/g, '-') + '.pdf';
    doc.save(filename);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate warning letter PDF');
  }
}