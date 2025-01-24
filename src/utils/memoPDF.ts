import { jsPDF } from 'jspdf';
import { Memo } from '../types/memo';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';

type MemoWithDetails = Memo & {
  department_name?: string;
  staff_name?: string;
};

export function generateMemoPDF(memo: MemoWithDetails) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/MEMO', y);
    y = PDFHelpers.addDate(doc, memo.created_at, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Memo Title
    const title = `ACHIEVEMENT MEMO - ${getMemoTypeLabel(memo.type)}`;
    y = PDFHelpers.addCenteredText(doc, title, y, PDF_CONSTANTS.FONT_SIZES.SUBTITLE, true);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Recipient Details
    y = PDFHelpers.addSectionHeading(doc, 'To:', y);
    if (memo.staff_name) {
      y = PDFHelpers.addWrappedText(doc, `Staff Member: ${memo.staff_name}`, y);
    } else if (memo.department_name) {
      y = PDFHelpers.addWrappedText(doc, `Department: ${memo.department_name}`, y);
    } else {
      y = PDFHelpers.addWrappedText(doc, 'All Staff', y);
    }
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Memo Subject
    y = PDFHelpers.addSectionHeading(doc, 'Subject:', y);
    y = PDFHelpers.addWrappedText(doc, memo.title, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Memo Content
    y = PDFHelpers.addWrappedText(doc, 'Dear valued team member(s),', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    y = PDFHelpers.addWrappedText(doc, memo.content, y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Closing
    y = PDFHelpers.addWrappedText(doc, 'Best regards,', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    y = PDFHelpers.addWrappedText(doc, 'Management', y);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    y = PDFHelpers.addWrappedText(doc, 'Muslimtravelbug Sdn Bhd', y);

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    const filename = `memo-${memo.title.toLowerCase().replace(/\s+/g, '-')}.pdf`;
    doc.save(filename);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate memo PDF');
  }
}

function getMemoTypeLabel(type: string): string {
  switch (type) {
    case 'recognition':
      return 'Recognition';
    case 'rewards':
      return 'Rewards';
    case 'bonus':
      return 'Bonus Eligible';
    case 'salary_increment':
      return 'Salary Increment';
    default:
      return type;
  }
}