import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';
import { ShowCauseLetter } from '../types/showCause';

export function generateShowCauseLetterPDF(companyName: string, letter: ShowCauseLetter) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(companyName, doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/SC', y);
    y = PDFHelpers.addDate(doc, letter.issued_date, y);

    // Letter Title
    const title = letter.content.type === 'misconduct' 
      ? 'SHOW CAUSE LETTER - ' + (letter.content.title || '').toUpperCase()
      : 'SHOW CAUSE LETTER - ' + letter.content.type.split('_').map(word => 
          word.charAt(0).toUpperCase() + word.slice(1)
        ).join(' ');
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

    y = PDFHelpers.addSectionHeading(doc, 'Description of Incident:', y);
    y = PDFHelpers.addWrappedText(doc, letter.content.description, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Response section if available
    if (letter.content.response) {
      y = PDFHelpers.addSectionHeading(doc, 'Your Response:', y);
      y = PDFHelpers.addWrappedText(doc, letter.content.response, y);
      if (letter.content.response_date) {
        y += PDF_CONSTANTS.LINE_HEIGHT;
        y = PDFHelpers.addWrappedText(doc, 'Response Date: ' + new Date(letter.content.response_date).toLocaleDateString(), y);
      }
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    // Signatures
    y = PDFHelpers.addSignatureSection(doc, y, 'CEO', letter.staff.name, department);

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    const filename = 'show-cause-letter-' + letter.staff.name.toLowerCase().replace(/\s+/g, '-') + '.pdf';
    doc.save(filename);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate show cause letter PDF');
  }
}