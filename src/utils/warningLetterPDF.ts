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
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Letter Title
    const title = `${letter.content.warning_level?.toUpperCase()} WARNING LETTER`;
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

    y = PDFHelpers.addWrappedText(doc, 'This letter serves as a formal warning regarding the following incident:', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    if (letter.content.incident_date) {
      y = PDFHelpers.addWrappedText(doc, `Incident Date: ${new Date(letter.content.incident_date).toLocaleDateString()}`, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (letter.content.description) {
      y = PDFHelpers.addSectionHeading(doc, 'Description of Incident:', y);
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
      y += PDF_CONSTANTS.LINE_HEIGHT * 2;
    }

    // Closing
    y = PDFHelpers.addWrappedText(doc, 'Please acknowledge receipt of this warning letter by signing below. Your signature indicates that you understand the contents of this letter and the seriousness of this matter.', y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Signatures
    y = PDFHelpers.addSignatureSection(doc, y, 'CEO', letter.staff.name, department);

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    doc.save(`warning-letter-${letter.staff.name.replace(/\s+/g, '-').toLowerCase()}.pdf`);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate warning letter PDF');
  }
}