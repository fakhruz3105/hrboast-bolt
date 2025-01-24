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
      "1": 4,
      "2": 3.5,
      "3": 4.5,
      "4": 4
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": 4.5,
      "2": 4,
      "3": 3.5
    }'::jsonb
    ELSE '{
      "1": 4,
      "2": 4.5,
      "3": 4
    }'::jsonb
  END as self_ratings,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": "Consistently writing clean code and following best practices",
      "2": "Completed all projects within deadlines",
      "3": "Active participation in team meetings",
      "4": "Proposed several process improvements"
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": "Successfully launched 3 major campaigns",
      "2": "Introduced new creative concepts",
      "3": "Improved campaign tracking methods"
    }'::jsonb
    ELSE '{
      "1": "Exceeded sales targets by 15%",
      "2": "Maintained 95% client satisfaction rate",
      "3": "Strong team player"
    }'::jsonb
  END as self_comments,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": 4.5,
      "2": 4,
      "3": 4,
      "4": 3.5
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": 4,
      "2": 4.5,
      "3": 4
    }'::jsonb
    ELSE '{
      "1": 4.5,
      "2": 4,
      "3": 4.5
    }'::jsonb
  END as manager_ratings,
  CASE ef.type
    WHEN 'quarter' THEN '{
      "1": "Excellent code quality and documentation",
      "2": "Good project management skills",
      "3": "Effective team communication",
      "4": "Shows good initiative"
    }'::jsonb
    WHEN 'half-year' THEN '{
      "1": "Strong campaign performance",
      "2": "Innovative approach to challenges",
      "3": "Good use of data insights"
    }'::jsonb
    ELSE '{
      "1": "Outstanding sales performance",
      "2": "Excellent client feedback",
      "3": "Great team collaboration"
    }'::jsonb
  END as manager_comments,
  4.2 as overall_rating,
  'completed' as status,
  now() - interval '1 month' as submitted_at,
  now() - interval '2 weeks' as completed_at
FROM evaluation_forms ef
CROSS JOIN staff_managers sm
WHERE ef.department_id = sm.department_id
LIMIT 5;

-- Add some pending evaluations
INSERT INTO evaluation_responses (
  evaluation_id,
  staff_id,
  manager_id,
  status,
  created_at
)
SELECT
  ef.id,
  s.id as staff_id,
  m.id as manager_id,
  'pending',
  now()
FROM evaluation_forms ef
JOIN staff s ON ef.department_id = s.department_id
JOIN staff m ON s.department_id = m.department_id
JOIN staff_levels sl ON m.level_id = sl.id
WHERE sl.name = 'HOD/Manager'
AND s.level_id IN (SELECT id FROM staff_levels WHERE name = 'Staff')
AND NOT EXISTS (
  SELECT 1 
  FROM evaluation_responses er 
  WHERE er.evaluation_id = ef.id 
  AND er.staff_id = s.id
)
LIMIT 5;