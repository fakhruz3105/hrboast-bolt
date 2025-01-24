-- Insert sample evaluation forms for different departments and types
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
    (
      'Q2 2024 Engineering Performance Review',
      'quarter',
      'Engineering',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Technical Skills",
          "title": "System Design",
          "description": "Ability to design scalable solutions",
          "weight": 25
        },
        {
          "id": "2",
          "category": "Problem Solving",
          "title": "Bug Resolution",
          "description": "Efficiency in debugging and problem solving",
          "weight": 25
        },
        {
          "id": "3",
          "category": "Documentation",
          "title": "Code Documentation",
          "description": "Quality of documentation and comments",
          "weight": 25
        },
        {
          "id": "4",
          "category": "Team Work",
          "title": "Collaboration",
          "description": "Effectiveness in team collaboration",
          "weight": 25
        }
      ]'
    ),
    (
      'H2 2024 Marketing Performance Review',
      'half-year',
      'Marketing',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Campaign Management",
          "title": "Campaign ROI",
          "description": "Return on investment for campaigns",
          "weight": 35
        },
        {
          "id": "2",
          "category": "Market Research",
          "title": "Market Analysis",
          "description": "Quality of market research and insights",
          "weight": 35
        },
        {
          "id": "3",
          "category": "Innovation",
          "title": "Creative Solutions",
          "description": "Development of innovative marketing strategies",
          "weight": 30
        }
      ]'
    ),
    (
      '2024 Annual Finance Team Review',
      'yearly',
      'Finance',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Financial Analysis",
          "title": "Accuracy",
          "description": "Accuracy in financial reporting",
          "weight": 40
        },
        {
          "id": "2",
          "category": "Compliance",
          "title": "Regulatory Compliance",
          "description": "Adherence to financial regulations",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Process Improvement",
          "title": "Efficiency",
          "description": "Contribution to process improvements",
          "weight": 30
        }
      ]'
    )
) AS data(title, type, department_name, level_name, criteria)
JOIN departments ON departments.name = data.department_name
JOIN staff_levels ON staff_levels.name = data.level_name;

-- Insert sample evaluation responses
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
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": 4.2,
      "2": 3.8,
      "3": 4.0,
      "4": 4.5
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": 4.3,
      "2": 4.1,
      "3": 3.9
    }'::jsonb
    ELSE '{
      "1": 4.4,
      "2": 4.2,
      "3": 4.1
    }'::jsonb
  END as self_ratings,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": "Implemented several system improvements",
      "2": "Resolved critical bugs efficiently",
      "3": "Maintained comprehensive documentation",
      "4": "Active participation in team projects"
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": "Achieved 20% increase in campaign ROI",
      "2": "Conducted detailed market analysis",
      "3": "Implemented new marketing strategies"
    }'::jsonb
    ELSE '{
      "1": "Maintained 99.9% accuracy in reports",
      "2": "Zero compliance issues",
      "3": "Automated several key processes"
    }'::jsonb
  END as self_comments,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": 4.3,
      "2": 4.0,
      "3": 3.9,
      "4": 4.4
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": 4.5,
      "2": 4.2,
      "3": 4.0
    }'::jsonb
    ELSE '{
      "1": 4.6,
      "2": 4.3,
      "3": 4.2
    }'::jsonb
  END as manager_ratings,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": "Strong technical skills demonstrated",
      "2": "Effective problem-solving approach",
      "3": "Good documentation practices",
      "4": "Excellent team player"
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": "Exceptional campaign performance",
      "2": "Thorough market analysis",
      "3": "Creative marketing solutions"
    }'::jsonb
    ELSE '{
      "1": "Outstanding accuracy in reporting",
      "2": "Strong compliance record",
      "3": "Valuable process improvements"
    }'::jsonb
  END as manager_comments,
  4.3 as overall_rating,
  'completed' as status,
  now() - interval '2 weeks' as submitted_at,
  now() - interval '1 week' as completed_at
FROM evaluation_forms ef
CROSS JOIN staff_managers sm
WHERE ef.department_id = sm.department_id
LIMIT 5;