/*
  # Insert Warning Letters Sample Data

  1. New Data
    - Sample warning letters for existing staff members
    - Mix of different warning levels and statuses
    - Realistic incident descriptions and improvement plans

  2. Data Structure
    - Links to existing staff records
    - Includes all required fields
    - Some with signed documents, some pending
*/

WITH staff_emails AS (
  SELECT id, email 
  FROM staff 
  WHERE email IN ('ahmad.ismail@company.com', 'david.tan@company.com')
)
INSERT INTO warning_letters (
  staff_id,
  warning_level,
  incident_date,
  description,
  improvement_plan,
  consequences,
  issued_date,
  signed_document_url
)
SELECT
  staff_emails.id,
  data.warning_level::warning_level,
  data.incident_date::date,
  data.description,
  data.improvement_plan,
  data.consequences,
  data.issued_date::date,
  data.signed_document_url
FROM (
  VALUES
    (
      'ahmad.ismail@company.com',
      'first',
      '2024-01-05',
      'Repeated tardiness and unauthorized absences over the past month. Employee has been late to work more than 5 times without proper notification.',
      'Must arrive at work on time (8:30 AM) and follow proper notification procedures for any absences. Attendance will be monitored daily for the next 30 days.',
      'Failure to improve attendance and punctuality may result in a second warning letter and possible disciplinary action.',
      '2024-01-08',
      NULL
    ),
    (
      'david.tan@company.com',
      'second',
      '2024-01-03',
      'Poor performance and failure to meet project deadlines. Multiple projects delivered late with quality issues.',
      'Must improve work quality and meet all project deadlines. Weekly progress reports required for the next 60 days.',
      'Failure to improve performance will result in a final warning and possible termination.',
      '2024-01-06',
      'warning-letters/signed-warning-2.pdf'
    ),
    (
      'david.tan@company.com',
      'final',
      '2024-01-15',
      'Continued poor performance despite previous warnings. Failed to show improvement in meeting deadlines and work quality.',
      'Immediate improvement required in all areas of performance. Daily progress reports and weekly review meetings for the next 30 days.',
      'Failure to demonstrate immediate and sustained improvement will result in termination of employment.',
      '2024-01-18',
      NULL
    )
) AS data(
  email,
  warning_level,
  incident_date,
  description,
  improvement_plan,
  consequences,
  issued_date,
  signed_document_url
)
JOIN staff_emails ON staff_emails.email = data.email
WHERE NOT EXISTS (
  SELECT 1 FROM warning_letters 
  WHERE staff_id = staff_emails.id 
  AND warning_level::text = data.warning_level
);