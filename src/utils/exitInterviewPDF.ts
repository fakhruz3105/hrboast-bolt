import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';

type ExitInterview = {
  staff: {
    name: string;
    department?: {
      name: string;
    };
  };
  content: {
    reason?: string;
    lastWorkingDate?: string;
    detailedReason?: string;
    suggestions?: string;
    handoverNotes?: string;
    exitChecklist?: Record<string, boolean>;
  };
};

export function generateExitInterviewPDF(companyName: string, interview: ExitInterview) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(companyName, doc, y);

    // Reference Number and Date
    y = PDFHelpers.addReferenceNumber(doc, 'MTB/EXIT', y);
    y = PDFHelpers.addDate(doc, new Date().toISOString(), y);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Form Title
    y = PDFHelpers.addTitle(doc, 'EXIT INTERVIEW FORM', y);

    // Staff Details
    y = PDFHelpers.addWrappedText(doc, 'Name: ' + interview.staff.name, y, true);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    y = PDFHelpers.addWrappedText(doc, 'Department: ' + (interview.staff.department?.name || 'N/A'), y, true);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Exit Details
    if (interview.content.reason) {
      y = PDFHelpers.addSectionHeading(doc, 'Primary Reason for Leaving:', y);
      y = PDFHelpers.addWrappedText(doc, formatReason(interview.content.reason), y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (interview.content.lastWorkingDate) {
      y = PDFHelpers.addSectionHeading(doc, 'Last Working Date:', y);
      y = PDFHelpers.addWrappedText(doc, new Date(interview.content.lastWorkingDate).toLocaleDateString(), y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (interview.content.detailedReason) {
      y = PDFHelpers.addSectionHeading(doc, 'Detailed Reason:', y);
      y = PDFHelpers.addWrappedText(doc, interview.content.detailedReason, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (interview.content.suggestions) {
      y = PDFHelpers.addSectionHeading(doc, 'Suggestions for Improvement:', y);
      y = PDFHelpers.addWrappedText(doc, interview.content.suggestions, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    if (interview.content.handoverNotes) {
      y = PDFHelpers.addSectionHeading(doc, 'Handover Notes:', y);
      y = PDFHelpers.addWrappedText(doc, interview.content.handoverNotes, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    // Exit Checklist
    if (interview.content.exitChecklist) {
      y = PDFHelpers.addSectionHeading(doc, 'Exit Checklist:', y);
      Object.entries(interview.content.exitChecklist).forEach(([key, value]) => {
        const label = key.split(/(?=[A-Z])/).join(' ').replace(/^\w/, c => c.toUpperCase());
        y = PDFHelpers.addWrappedText(doc, `☐ ${label}: ${value ? 'Completed' : 'Pending'}`, y);
        y += PDF_CONSTANTS.LINE_HEIGHT;
      });
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    // Signatures
    y = PDFHelpers.addSignatureSection(doc, y, 'CEO', interview.staff.name, interview.staff.department?.name || 'N/A');

    // Add footer
    PDFHelpers.addFooter(doc);

    // Save the PDF
    doc.save(`exit-interview-${interview.staff.name.replace(/\s+/g, '-').toLowerCase()}.pdf`);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate exit interview PDF');
  }
}

function formatReason(reason?: string): string {
  if (!reason) return '-';
  return reason.split('_').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ');
}