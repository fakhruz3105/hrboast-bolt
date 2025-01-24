import { jsPDF } from 'jspdf';

// Constants for consistent spacing
export const PDF_CONSTANTS = {
  MARGIN: 20,
  LINE_HEIGHT: 8,
  SECTION_SPACING: 16,
  PARAGRAPH_SPACING: 12,
  HEADER_SPACING: 24,
  SIGNATURE_SPACING: 60,
  FONT_SIZES: {
    TITLE: 14,
    SUBTITLE: 12,
    HEADING: 11,
    NORMAL: 10,
    SMALL: 8
  },
  COLORS: {
    TEXT: {
      PRIMARY: '#000000',
      SECONDARY: '#4B5563',
      MUTED: '#6B7280'
    },
    LINE: '#E5E7EB'
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

  addCompanyHeader(doc: jsPDF, y: number) {
    const pageWidth = doc.internal.pageSize.width;
    const companyName = 'MUSLIMTRAVELBUG SDN BHD';

    // Add company name
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.TITLE);
    doc.setFont('helvetica', 'bold');
    const companyNameWidth = doc.getTextWidth(companyName);
    doc.text(companyName, (pageWidth - companyNameWidth) / 2, y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    return y;
  },

  addReferenceNumber(doc: jsPDF, prefix: string, y: number) {
    const refNo = `${prefix}/${new Date().getFullYear()}/${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`;
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.text(`Ref: ${refNo}`, PDF_CONSTANTS.MARGIN, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT;
  },

  addDate(doc: jsPDF, date: string, y: number) {
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    doc.text(`Date: ${new Date(date).toLocaleDateString()}`, PDF_CONSTANTS.MARGIN, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT * 1.5;
  },

  addCenteredText(doc: jsPDF, text: string, y: number, fontSize: number, bold: boolean = false) {
    const pageWidth = doc.internal.pageSize.width;
    doc.setFontSize(fontSize);
    doc.setFont('helvetica', bold ? 'bold' : 'normal');
    const textWidth = doc.getTextWidth(text);
    doc.text(text, (pageWidth - textWidth) / 2, y);
    return y + PDF_CONSTANTS.LINE_HEIGHT * 1.5;
  },

  addWrappedText(doc: jsPDF, text: string, y: number) {
    const pageWidth = doc.internal.pageSize.width;
    const maxWidth = pageWidth - (PDF_CONSTANTS.MARGIN * 2);
    const lines = doc.splitTextToSize(text, maxWidth);
    
    for (const line of lines) {
      if (y > doc.internal.pageSize.height - PDF_CONSTANTS.MARGIN * 2) {
        doc.addPage();
        y = PDF_CONSTANTS.MARGIN;
      }
      doc.text(line, PDF_CONSTANTS.MARGIN, y);
      y += PDF_CONSTANTS.LINE_HEIGHT;
    }

    return y + PDF_CONSTANTS.LINE_HEIGHT * 0.5;
  },

  addSectionHeading(doc: jsPDF, text: string, y: number) {
    if (y > doc.internal.pageSize.height - PDF_CONSTANTS.MARGIN * 3) {
      doc.addPage();
      y = PDF_CONSTANTS.MARGIN;
    }

    doc.setFont('helvetica', 'bold');
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.HEADING);
    doc.text(text, PDF_CONSTANTS.MARGIN, y);
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.NORMAL);
    return y + PDF_CONSTANTS.LINE_HEIGHT * 1.5;
  },

  addTable(doc: jsPDF, data: string[][], y: number, columnWidths: number[], allowPageBreak: boolean = false) {
    const pageWidth = doc.internal.pageSize.width;
    const startX = PDF_CONSTANTS.MARGIN;
    const cellPadding = 3;
    let currentY = y;

    // Calculate total width percentage
    const totalWidth = columnWidths.reduce((a, b) => a + b, 0);
    
    // Convert percentage widths to actual widths
    const actualWidths = columnWidths.map(width => 
      ((pageWidth - (PDF_CONSTANTS.MARGIN * 2)) * (width / 100))
    );

    for (let rowIndex = 0; rowIndex < data.length; rowIndex++) {
      const row = data[rowIndex];
      let maxHeight = PDF_CONSTANTS.LINE_HEIGHT;

      // Calculate max height for this row
      for (let colIndex = 0; colIndex < row.length; colIndex++) {
        const cellText = row[colIndex];
        const cellWidth = actualWidths[colIndex] - (cellPadding * 2);
        const lines = doc.splitTextToSize(cellText, cellWidth);
        const cellHeight = lines.length * PDF_CONSTANTS.LINE_HEIGHT;
        maxHeight = Math.max(maxHeight, cellHeight);
      }

      // Check if we need to add a new page
      if (currentY + maxHeight > doc.internal.pageSize.height - PDF_CONSTANTS.MARGIN && allowPageBreak) {
        doc.addPage();
        currentY = PDF_CONSTANTS.MARGIN;
        
        // If this is not the first row and we're starting a new page, repeat the header
        if (rowIndex > 0) {
          const headerRow = data[0];
          let x = startX;
          
          doc.setFont('helvetica', 'bold');
          for (let i = 0; i < headerRow.length; i++) {
            const cellWidth = actualWidths[i] - (cellPadding * 2);
            const lines = doc.splitTextToSize(headerRow[i], cellWidth);
            doc.text(lines, x + cellPadding, currentY + PDF_CONSTANTS.LINE_HEIGHT);
            x += actualWidths[i];
          }
          doc.setFont('helvetica', 'normal');
          
          currentY += maxHeight + cellPadding;
          continue;
        }
      }

      // Draw cells
      let x = startX;
      for (let colIndex = 0; colIndex < row.length; colIndex++) {
        const cellText = row[colIndex];
        const cellWidth = actualWidths[colIndex] - (cellPadding * 2);
        const lines = doc.splitTextToSize(cellText, cellWidth);
        
        // Set bold for header row
        if (rowIndex === 0) {
          doc.setFont('helvetica', 'bold');
        }
        
        doc.text(lines, x + cellPadding, currentY + PDF_CONSTANTS.LINE_HEIGHT);
        
        // Reset font after header row
        if (rowIndex === 0) {
          doc.setFont('helvetica', 'normal');
        }
        
        x += actualWidths[colIndex];
      }

      currentY += maxHeight + cellPadding;
    }

    return currentY;
  },

  addSignatureSection(doc: jsPDF, y: number, manager: string, staff: string, department: string) {
    const pageWidth = doc.internal.pageSize.width;
    const signatureWidth = (pageWidth - (PDF_CONSTANTS.MARGIN * 3)) / 2;

    if (y > doc.internal.pageSize.height - PDF_CONSTANTS.SIGNATURE_SPACING) {
      doc.addPage();
      y = PDF_CONSTANTS.MARGIN;
    }

    y += PDF_CONSTANTS.SIGNATURE_SPACING;

    // Manager signature
    doc.line(PDF_CONSTANTS.MARGIN, y, PDF_CONSTANTS.MARGIN + signatureWidth, y);
    y += PDF_CONSTANTS.LINE_HEIGHT * 1.5;
    doc.text(manager, PDF_CONSTANTS.MARGIN, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text('CEO', PDF_CONSTANTS.MARGIN, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text('Muslimtravelbug Sdn Bhd', PDF_CONSTANTS.MARGIN, y);

    // Staff signature
    const staffX = pageWidth - PDF_CONSTANTS.MARGIN - signatureWidth;
    y -= PDF_CONSTANTS.LINE_HEIGHT * 2;
    doc.line(staffX, y - PDF_CONSTANTS.LINE_HEIGHT, pageWidth - PDF_CONSTANTS.MARGIN, y - PDF_CONSTANTS.LINE_HEIGHT);
    doc.text(staff, staffX, y);
    y += PDF_CONSTANTS.LINE_HEIGHT;
    doc.text(department, staffX, y);

    return y;
  },

  addFooter(doc: jsPDF) {
    const pageCount = doc.getNumberOfPages();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;
    const address = '28-3 Jalan Equine 1D Taman Equine 43300 Seri Kembangan Selangor';
    const phone = 'Tel: 03 95441442';

    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.setFontSize(PDF_CONSTANTS.FONT_SIZES.SMALL);
      doc.setTextColor(PDF_CONSTANTS.COLORS.TEXT.MUTED);
      
      // Add address and phone
      const addressWidth = doc.getTextWidth(address);
      const phoneWidth = doc.getTextWidth(phone);
      doc.text(address, (pageWidth - addressWidth) / 2, pageHeight - PDF_CONSTANTS.MARGIN - PDF_CONSTANTS.LINE_HEIGHT);
      doc.text(phone, (pageWidth - phoneWidth) / 2, pageHeight - PDF_CONSTANTS.MARGIN);
    }
  }
};