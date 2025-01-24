-- Insert additional evaluation forms
INSERT INTO evaluation_forms (
  title,
  type,
  department_id,
  level_id,
  criteria
)
SELECT
  data.title,
  data.type::evaluation_type,
  departments.id as department_id,
  staff_levels.id as level_id,
  data.criteria::jsonb
FROM (
  VALUES
    -- Quarter Evaluations
    (
      'Q1 2024 Sales Performance Review',
      'quarter',
      'Sales',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Sales Performance",
          "title": "Sales Target Achievement",
          "description": "Meeting or exceeding quarterly sales targets",
          "weight": 40
        },
        {
          "id": "2",
          "category": "Client Relations",
          "title": "Client Management",
          "description": "Quality of client relationships and satisfaction",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Pipeline Management",
          "title": "Sales Pipeline",
          "description": "Effectiveness in managing sales pipeline",
          "weight": 30
        }
      ]'
    ),
    (
      'Q1 2024 HR Team Evaluation',
      'quarter',
      'Human Resources',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Recruitment",
          "title": "Hiring Efficiency",
          "description": "Time-to-hire and quality of candidates",
          "weight": 35
        },
        {
          "id": "2",
          "category": "Employee Relations",
          "title": "Employee Satisfaction",
          "description": "Management of employee concerns and satisfaction",
          "weight": 35
        },
        {
          "id": "3",
          "category": "Documentation",
          "title": "HR Documentation",
          "description": "Accuracy and completeness of HR records",
          "weight": 30
        }
      ]'
    ),
    -- Half-Year Evaluations
    (
      'H1 2024 Finance Team Review',
      'half-year',
      'Finance',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Financial Analysis",
          "title": "Reporting Accuracy",
          "description": "Accuracy and timeliness of financial reports",
          "weight": 40
        },
        {
          "id": "2",
          "category": "Compliance",
          "title": "Regulatory Compliance",
          "description": "Adherence to financial regulations and policies",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Process Improvement",
          "title": "Efficiency",
          "description": "Implementation of process improvements",
          "weight": 30
        }
      ]'
    ),
    (
      'H1 2024 Engineering Performance Review',
      'half-year',
      'Engineering',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Technical Skills",
          "title": "Technical Proficiency",
          "description": "Mastery of required technical skills",
          "weight": 35
        },
        {
          "id": "2",
          "category": "Project Delivery",
          "title": "Project Management",
          "description": "Ability to deliver projects on time",
          "weight": 35
        },
        {
          "id": "3",
          "category": "Innovation",
          "title": "Technical Innovation",
          "description": "Contribution to technical improvements",
          "weight": 30
        }
      ]'
    ),
    -- Yearly Evaluation
    (
      '2024 Marketing Department Annual Review',
      'yearly',
      'Marketing',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Campaign Performance",
          "title": "Marketing Campaigns",
          "description": "Overall success of marketing initiatives",
          "weight": 35
        },
        {
          "id": "2",
          "category": "Brand Management",
          "title": "Brand Development",
          "description": "Contribution to brand growth and awareness",
          "weight": 35
        },
        {
          "id": "3",
          "category": "Digital Marketing",
          "title": "Digital Presence",
          "description": "Management of digital marketing channels",
          "weight": 30
        }
      ]'
    )
) AS data(title, type, department_name, level_name, criteria)
JOIN departments ON departments.name = data.department_name
JOIN staff_levels ON staff_levels.name = data.level_name;

-- Insert corresponding evaluation responses
WITH staff_managers AS (
  SELECT 
    s.id as staff_id,
    s.department_id,
    m.id as manager_id
  FROM staff s
  JOIN staff m ON s.department_id = m.department_id
  JOIN staff_levels sl ON m.level_id = sl.id
  WHERE sl.name = 'HOD/Manager'
  AND s.level_id IN (SELECT id FROM staff_levels WHERE name = 'Staff')
)
INSERT INTO evaluation_responses (
  evaluation_id,
  staff_id,
  manager_id,
  self_ratings,
  self_comments,
  manager_ratings,
  manager_comments,
  overall_rating,
  status,
  submitted_at,
  completed_at
)
SELECT
  ef.id as evaluation_id,
  sm.staff_id,
  sm.manager_id,
  '{
    "1": 4.2,
    "2": 4.0,
    "3": 3.8
  }'::jsonb as self_ratings,
  '{
    "1": "Met all key objectives for the period",
    "2": "Maintained strong relationships with stakeholders",
    "3": "Identified areas for improvement"
  }'::jsonb as self_comments,
  '{
    "1": 4.0,
    "2": 4.2,
    "3": 3.9
  }'::jsonb as manager_ratings,
  '{
    "1": "Demonstrated consistent performance",
    "2": "Shows strong leadership potential",
    "3": "Good team player with room for growth"
  }'::jsonb as manager_comments,
  4.0 as overall_rating,
  'completed' as status,
  now() - interval '1 month' as submitted_at,
  now() - interval '2 weeks' as completed_at
FROM evaluation_forms ef
CROSS JOIN staff_managers sm
WHERE ef.department_id = sm.department_id
AND NOT EXISTS (
  SELECT 1 
  FROM evaluation_responses er 
  WHERE er.evaluation_id = ef.id 
  AND er.staff_id = sm.staff_id
)
LIMIT 5;