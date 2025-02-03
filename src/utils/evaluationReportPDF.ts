import { jsPDF } from 'jspdf';
import { PDF_CONSTANTS, PDFHelpers } from './pdfUtils';
import { EvaluationResponse } from '../types/evaluation';

export function generateEvaluationReportPDF(companyName: string, evaluation: EvaluationResponse) {
  const doc = PDFHelpers.createDocument();
  let y = PDF_CONSTANTS.MARGIN;

  try {
    // Add header
    y = PDFHelpers.addCompanyHeader(companyName, doc, y);

    // Add title and reference in a compact format
    const headerTable = [
      ['EVALUATION REPORT', `Ref: MTB/EVAL/${new Date().getFullYear()}/${Math.floor(Math.random() * 1000).toString().padStart(3, '0')}`],
      [`Type: ${evaluation.evaluation?.type.toUpperCase()}`, `Date: ${new Date(evaluation.completed_at || evaluation.created_at).toLocaleDateString()}`]
    ];
    y = PDFHelpers.addTable(doc, headerTable, y, [60, 40]);
    y += PDF_CONSTANTS.LINE_HEIGHT;

    // Staff and Manager Details in a compact table
    const department = evaluation.staff?.departments?.find(d => d.is_primary)?.department?.name || 'N/A';
    const detailsTable = [
      ['Staff Details', 'Evaluation Details'],
      [`Name: ${evaluation.staff?.name || 'N/A'}`, `Status: ${evaluation.status.toUpperCase()}`],
      [`Department: ${department}`, `Score: ${evaluation.percentage_score ? `${evaluation.percentage_score.toFixed(1)}%` : 'N/A'}`],
      [`Manager: ${evaluation.manager?.name || 'N/A'}`, '']
    ];
    y = PDFHelpers.addTable(doc, detailsTable, y, [60, 40]);
    y += PDF_CONSTANTS.LINE_HEIGHT * 2;

    // Evaluation Questions and Responses in a table format
    const questionsHeader = ['Question', 'Self Rating', 'Manager Rating'];
    const questionsData = [questionsHeader];

    evaluation.evaluation?.questions.forEach((question) => {
      questionsData.push([
        `${question.category}\n${question.question}`,
        evaluation.self_ratings[question.id]?.toString() || 'N/A',
        evaluation.manager_ratings[question.id]?.toString() || 'N/A'
      ]);
    });

    y = PDFHelpers.addTable(doc, questionsData, y, [60, 20, 20], true);
    y += PDF_CONSTANTS.LINE_HEIGHT * 4; // Add more space before signatures

    // Signatures in a table format with more spacing
    const signatureTable = [
      ['Manager Signature', 'Staff Signature'],
      ['\n\n\n', '\n\n\n'], // Add more newlines for signature space
      [`${evaluation.manager?.name || 'Manager'}`, `${evaluation.staff?.name || 'Staff Member'}`],
      ['CEO', department],
      ['Muslimtravelbug Sdn Bhd', '']
    ];
    y = PDFHelpers.addTable(doc, signatureTable, y, [50, 50]);

    // Add footer with page numbers
    PDFHelpers.addFooter(doc);

    // Save the PDF
    const filename = `evaluation-report-${evaluation.staff?.name.toLowerCase().replace(/\s+/g, '-')}-${evaluation.evaluation?.type}.pdf`;
    doc.save(filename);
  } catch (error) {
    console.error('Error generating PDF:', error);
    throw new Error('Failed to generate evaluation report PDF');
  }
}