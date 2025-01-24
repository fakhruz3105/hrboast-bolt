import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';

type ShowCauseLetter = {
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
    type: string;
    title?: string;
    incident_date: string;
    description: string;
    response?: string;
    response_date?: string;
  };
  issued_date: string;
};

export function generateShowCauseLetterPDF(letter: ShowCauseLetter) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/SC', y);
    y = PDFHelpers.addDate(doc, letter.issued_date, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Letter Title
    const title = letter.content.type === 'misconduct' 
      ? `SHOW CAUSE LETTER - ${letter.content.title?.toUpperCase()}`
      : `SHOW CAUSE LETTER - ${letter.content.type.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}`;
    y = PDFHelpers.addCenteredText(doc, title, y, PDF_CONSTANTS.FONT_SIZES.SUBTITLE, true);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Staff Details
    const department = letter.staff.departments?.find(d => d.is_primary)?.department?.name || 'N/A';
    y = PDFHelpers.addWrappedText(doc, `Name: ${letter.staff.name}`, y);
    y = PDFHelpers.addWrappedText(doc, `Department: ${department}`, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Letter Content
    y = PDFHelpers.addWrappedText(doc, 'Dear Sir/Madam,', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    y = PDFHelpers.addWrappedText(doc, 'You are hereby required to provide a written explanation regarding the following matter:', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    if (letter.content.incident_date) {
      y = PDFHelpers.addWrappedText(doc, `Incident Date: ${new Date(letter.content.incident_date).toLocaleDateString()}`, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    y = PDFHelpers.addSectionHeading(doc, 'Description of Incident:', y);
    y = PDFHelpers.addWrappedText(doc, letter.content.description, y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Response section
    if (letter.content.response) {
      y = PDFHelpers.addSectionHeading(doc, 'Your Response:', y);
      y = PDFHelpers.addWrappedText(doc, letter.content.response, y);
      if (letter.content.response_date) {
        y += PDF_CONSTANTS.LINE_HEIGHT;
        y = PDFHelpers.addWrappedText(doc, `Response Date: ${new Date(letter.content.response_date).toLocaleDateString()}`, y);
      }
      y += PDF_CONSTANTS.LINE_HEIGHT;
    } else {
      y = PDFHelpers.addWrappedText(doc, 'Please provide your written explanation within 24 hours from the date of this letter. Your response should address the above matter comprehensively and include any relevant supporting documentation.', y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
      
      y = PDFHelpers.addWrappedText(doc, 'Failure to respond within the stipulated time frame may result in disciplinary action being taken against you without further reference to you.', y);
      y += PDF_CONSTANTS.LINE_HEIGHT * 2;
    }

    // Signatures
    y = PDFHelpers.addSignatureSection(doc, y, 'CEO', letter.staff.name, department);

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    doc.save(`show-cause-letter-${letter.staff.name.replace(/\s+/g, '-').toLowerCase()}.pdf`);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate show cause letter PDF');
  }
}