import { jsPDF } from 'jspdf';

// Constants for consistent spacing
export const PDF_CONSTANTS = {
  MARGIN: 25,
  LINE_HEIGHT: 5,
  SECTION_SPACING: 10,
  PARAGRAPH_SPACING: 8,
  HEADER_SPACING: 15,
  SIGNATURE_SPACING: 35,
  HEADER_HEIGHT: 25,
  FOOTER_HEIGHT: 20,
  FONT_SIZES: {
    COMPANY: 16,
    TITLE: 14,
    SUBTITLE: 14,
    HEADING: 11,
    NORMAL: 10,
    SMALL: 8
  },
  COLORS: {
    TEXT: {
      PRIMARY: '#000000',
      SECONDARY: '#4B5563',
      MUTED: '#6B7280',
      RED: '#DC2626'
    },
    BACKGROUND: {
      HEADER: '#EBF8FF',
      FOOTER: '#EBF8FF'
    }
  }
};

// Helper functions for PDF generation
export const PDFHelpers = {
  createDocument() {
    const doc = new jsPDF();
    doc.setFont('helvetica');
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    return doc;
  },

  addCompanyHeader(companyName: string, doc: jsPDF, y: number) {
    const pageWidth = doc.internal.pageSize.width;
    
    // Add header background
    doc.setFillColor(PDF_CONSTANTS.COLORS.BACKGROUND.HEADER);
    doc.rect(0, 0, pageWidth, PDF_CONSTANTS.HEADER_HEIGHT, 'F');

    // Start y position from top
    y = 10;

    // Left side - Company name and tagline
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.COMPANY);
    doc.setFont('helvetica', 'bold');
    doc.text(companyName, PDF_CONSTANTS.MARGIN, y);
    
    // Add tagline below company name
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.SMALL);
    doc.setFont('helvetica', 'normal');
    doc.text('by hrboast.com', PDF_CONSTANTS.MARGIN, y + 5);

    // Right side - Private & Confidential in red
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(PDF_CONSTANTS.COLORS.TEXT.RED);
    const confidentialText = 'Private & Confidential';
    const confidentialWidth = doc.getTextWidth(confidentialText);
    doc.text(confidentialText, pageWidth - PDF_CONSTANTS.MARGIN - confidentialWidth, y);

    // Reset text color
    doc.setTextColor(PDF_CONSTANTS.COLORS.TEXT.PRIMARY);
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.setFont('helvetica', 'normal');

    // Add extra spacing after header
    return PDF_CONSTANTS.HEADER_HEIGHT + 15;
  },

  addReferenceNumber(doc: jsPDF, prefix: string, y: number) {
    const pageWidth = doc.internal.pageSize.width;
    const refNo = `${prefix}/${new Date().getFullYear()}/${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`;
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    const refText = `Ref: ${refNo}`;
    const refWidth = doc.getTextWidth(refText);
    doc.text(refText, pageWidth - PDF_CONSTANTS.MARGIN - refWidth, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT;
  },

  addDate(doc: jsPDF, date: string, y: number) {
    const pageWidth = doc.internal.pageSize.width;
    const dateText = `Date: ${new Date(date).toLocaleDateString()}`;
    const dateWidth = doc.getTextWidth(dateText);
    doc.text(dateText, pageWidth - PDF_CONSTANTS.MARGIN - dateWidth, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT * 2;
  },

  addTitle(doc: jsPDF, title: string, y: number) {
    // Add "Subject:" prefix with same size as title
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.TITLE);
    doc.setFont('helvetica', 'bold');
    doc.text('Subject:', PDF_CONSTANTS.MARGIN, y);
    
    // Add title with underline
    const titleX = PDF_CONSTANTS.MARGIN + doc.getTextWidth('Subject: ');
    doc.text(title, titleX, y);
    
    // Add underline
    const titleWidth = doc.getTextWidth(title);
    doc.line(titleX, y + 1, titleX + titleWidth, y + 1);
    
    // Reset font settings
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.setFont('helvetica', 'normal');
    
    return y + PDF_CONSTANTS.LINE_HEIGHT * 3;
  },

  addSalutation(doc: jsPDF, y: number) {
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.text('Sir/Madam,', PDF_CONSTANTS.MARGIN, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT * 2;
  },

  addWrappedText(doc: jsPDF, text: string, y: number, boldLabel: boolean = false) {
    const colonIndex = text.indexOf(':');
    if (colonIndex !== -1 && boldLabel) {
      // Bold the label part (before the colon)
      const label = text.substring(0, colonIndex + 1);
      const value = text.substring(colonIndex + 1);
      
      doc.setFont('helvetica', 'bold');
      doc.text(label, PDF_CONSTANTS.MARGIN, y);
      
      doc.setFont('helvetica', 'normal');
      const labelWidth = doc.getTextWidth(label + ' '); // Add space after colon
      doc.text(' ' + value.trim(), PDF_CONSTANTS.MARGIN + labelWidth, y); // Add space before value
    } else {
      doc.text(text, PDF_CONSTANTS.MARGIN, y);
    }
    
    return y;
  },

  addSectionHeading(doc: jsPDF, text: string, y: number) {
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.HEADING);
    doc.text(text, PDF_CONSTANTS.MARGIN, y);
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    return y + PDF_CONSTANTS.LINE_HEIGHT;
  },

  addSignatureSection(doc: jsPDF, y: number, manager: string, staff: string, department: string) {
    const pageWidth = doc.internal.pageSize.width;
    const signatureWidth = (pageWidth - (PDF_CONSTANTS.MARGIN * 3)) / 2;
    const rightX = pageWidth - PDF_CONSTANTS.MARGIN - signatureWidth;

    // Add spacing before signatures
    y += PDF_CONSTANTS.SIGNATURE_SPACING;

    // Add "Approved by" and "Accepted by" at the same height
    doc.setFont('helvetica', 'normal');
    doc.text('Approved by :', PDF_CONSTANTS.MARGIN, y);
    doc.text('Accepted by :', rightX, y);

    // Add signature lines
    y += PDF_CONSTANTS.LINE_HEIGHT * 4;
    doc.line(PDF_CONSTANTS.MARGIN, y, PDF_CONSTANTS.MARGIN + signatureWidth, y);
    doc.line(rightX, y, pageWidth - PDF_CONSTANTS.MARGIN, y);

    // Add names and details
    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text('Name:', PDF_CONSTANTS.MARGIN, y);
    doc.text(staff, rightX, y);

    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text('Muslimtravelbug Sdn Bhd', PDF_CONSTANTS.MARGIN, y);
    doc.text(department, rightX, y);

    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text('Date : ', rightX, y);

    return y;
  },

  addFooter(doc: jsPDF) {
    const pageCount = doc.getNumberOfPages();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;

    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);

      // Add footer background
      doc.setFillColor(PDF_CONSTANTS.COLORS.BACKGROUND.FOOTER);
      doc.rect(0, pageHeight - PDF_CONSTANTS.FOOTER_HEIGHT, pageWidth, PDF_CONSTANTS.FOOTER_HEIGHT, 'F');

      // Add footer text
      doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.SMALL);
      doc.setTextColor(PDF_CONSTANTS.COLORS.TEXT.MUTED);

      // Combine address, phone and email on one line
      const footerText = '28-3 Jalan Equine 1D Taman Equine 43300 Seri Kembangan Selangor | Tel: 03 95441442 | Email: hr@muslimtravelbug.com';
      const footerWidth = doc.getTextWidth(footerText);
      doc.text(footerText, (pageWidth - footerWidth) / 2, pageHeight - 10);

      doc.setTextColor(PDF_CONSTANTS.COLORS.TEXT.PRIMARY);
    }
  }
};