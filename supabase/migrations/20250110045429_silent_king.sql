-- First clean up existing evaluation data
DELETE FROM evaluation_responses;
DELETE FROM evaluation_forms;

-- Insert evaluation forms
INSERT INTO evaluation_forms (
  title,
  type,
  questions
)
VALUES
  (
    'Q1 2024 Performance Review',
    'quarter',
    '[
      {
        "id": "1",
        "category": "Job Knowledge",
        "question": "Demonstrates understanding of job requirements and technical skills",
        "description": "Evaluate the employee''s proficiency in required job skills and knowledge"
      },
      {
        "id": "2",
        "category": "Quality of Work",
        "question": "Produces high-quality work consistently",
        "description": "Assess accuracy, thoroughness, and reliability of work output"
      },
      {
        "id": "3",
        "category": "Communication",
        "question": "Communicates effectively with team members and stakeholders",
        "description": "Evaluate verbal and written communication skills"
      },
      {
        "id": "4",
        "category": "Initiative",
        "question": "Shows initiative and proactively identifies improvements",
        "description": "Assess self-motivation and contribution to process improvements"
      },
      {
        "id": "5",
        "category": "Teamwork",
        "question": "Works effectively as part of a team",
        "description": "Evaluate collaboration and team contribution"
      }
    ]'
  ),
  (
    'H1 2024 Mid-Year Review',
    'half-year',
    '[
      {
        "id": "1",
        "category": "Performance Goals",
        "question": "Achievement of set performance targets",
        "description": "Evaluate progress towards annual performance goals"
      },
      {
        "id": "2",
        "category": "Leadership",
        "question": "Demonstrates leadership qualities and mentorship",
        "description": "Assess leadership capabilities and team guidance"
      },
      {
        "id": "3",
        "category": "Innovation",
        "question": "Contributes innovative ideas and solutions",
        "description": "Evaluate creativity and problem-solving abilities"
      },
      {
        "id": "4",
        "category": "Professional Development",
        "question": "Pursues professional growth and learning",
        "description": "Assess commitment to skill development"
      }
    ]'
  ),
  (
    '2024 Annual Performance Evaluation',
    'yearly',
    '[
      {
        "id": "1",
        "category": "Overall Performance",
        "question": "Annual performance and goal achievement",
        "description": "Comprehensive evaluation of yearly performance"
      },
      {
        "id": "2",
        "category": "Career Growth",
        "question": "Professional development and career progression",
        "description": "Assess growth and advancement over the year"
      },
      {
        "id": "3",
        "category": "Impact",
        "question": "Contribution to company objectives",
        "description": "Evaluate impact on organizational goals"
      },
      {
        "id": "4",
        "category": "Leadership",
        "question": "Leadership and influence",
        "description": "Assess leadership impact and team development"
      }
    ]'
  );

-- Insert evaluation responses for various staff members
DO $$
DECLARE
  v_evaluation_id uuid;
  v_staff_record RECORD;
  v_manager_record RECORD;
BEGIN
  -- Get the quarterly evaluation form ID
  SELECT id INTO v_evaluation_id 
  FROM evaluation_forms 
  WHERE type = 'quarter' 
  LIMIT 1;

  -- Create completed evaluations
  FOR v_staff_record IN (
    SELECT s.id, s.name 
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name = 'Staff'
    AND slj.is_primary = true
    LIMIT 5
  ) LOOP
    -- Get a manager for this staff member
    SELECT s.id INTO v_manager_record
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name = 'HOD/Manager'
    AND slj.is_primary = true
    LIMIT 1;

    -- Insert completed evaluation
    INSERT INTO evaluation_responses (
      evaluation_id,
      staff_id,
      manager_id,
      self_ratings,
      self_comments,
      manager_ratings,
      manager_comments,
      percentage_score,
      status,
      submitted_at,
      completed_at
    ) VALUES (
      v_evaluation_id,
      v_staff_record.id,
      v_manager_record.id,
      '{
        "1": 4,
        "2": 4,
        "3": 5,
        "4": 4,
        "5": 5
      }',
      '{
        "1": "Continuously improving technical skills",
        "2": "Maintaining high quality standards",
        "3": "Active participation in team discussions",
        "4": "Proposed several process improvements",
        "5": "Strong team player",
        "overall": "Had a productive quarter with significant improvements"
      }',
      '{
        "1": 4,
        "2": 5,
        "3": 4,
        "4": 4,
        "5": 5
      }',
      '{
        "1": "Shows good technical proficiency",
        "2": "Excellent attention to detail",
        "3": "Communicates clearly and effectively",
        "4": "Takes initiative in problem-solving",
        "5": "Great team collaboration",
        "overall": "Strong performance this quarter"
      }',
      88.0,
      'completed',
      now() - interval '2 weeks',
      now() - interval '1 week'
    );
  END LOOP;

  -- Create pending evaluations
  FOR v_staff_record IN (
    SELECT s.id, s.name 
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name = 'Staff'
    AND slj.is_primary = true
    LIMIT 3
  ) LOOP
    -- Get a manager for this staff member
    SELECT s.id INTO v_manager_record
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name = 'HOD/Manager'
    AND slj.is_primary = true
    LIMIT 1;

    -- Insert pending evaluation
    INSERT INTO evaluation_responses (
      evaluation_id,
      staff_id,
      manager_id,
      status,
      created_at
    ) VALUES (
      v_evaluation_id,
      v_staff_record.id,
      v_manager_record.id,
      'pending',
      now()
    );
  END LOOP;

  -- Get the half-year evaluation form ID
  SELECT id INTO v_evaluation_id 
  FROM evaluation_forms 
  WHERE type = 'half-year' 
  LIMIT 1;

  -- Create some completed half-year evaluations
  FOR v_staff_record IN (
    SELECT s.id, s.name 
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name IN ('Staff', 'HR')
    AND slj.is_primary = true
    LIMIT 4
  ) LOOP
    -- Get a manager for this staff member
    SELECT s.id INTO v_manager_record
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name = 'HOD/Manager'
    AND slj.is_primary = true
    LIMIT 1;

    -- Insert completed evaluation
    INSERT INTO evaluation_responses (
      evaluation_id,
      staff_id,
      manager_id,
      self_ratings,
      self_comments,
      manager_ratings,
      manager_comments,
      percentage_score,
      status,
      submitted_at,
      completed_at
    ) VALUES (
      v_evaluation_id,
      v_staff_record.id,
      v_manager_record.id,
      '{
        "1": 4,
        "2": 5,
        "3": 4,
        "4": 4
      }',
      '{
        "1": "Met most performance targets",
        "2": "Actively mentoring junior team members",
        "3": "Implemented several process improvements",
        "4": "Completed relevant certifications",
        "overall": "Strong first half of the year with good progress on goals"
      }',
      '{
        "1": 5,
        "2": 4,
        "3": 5,
        "4": 4
      }',
      '{
        "1": "Exceeded performance expectations",
        "2": "Shows strong leadership potential",
        "3": "Valuable innovative contributions",
        "4": "Good progress in professional development",
        "overall": "Excellent performance and growth"
      }',
      90.0,
      'completed',
      now() - interval '1 month',
      now() - interval '3 weeks'
    );
  END LOOP;

  -- Get the yearly evaluation form ID
  SELECT id INTO v_evaluation_id 
  FROM evaluation_forms 
  WHERE type = 'yearly' 
  LIMIT 1;

  -- Create some completed yearly evaluations
  FOR v_staff_record IN (
    SELECT s.id, s.name 
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name IN ('HOD/Manager', 'Staff')
    AND slj.is_primary = true
    LIMIT 3
  ) LOOP
    -- Get a manager for this staff member
    SELECT s.id INTO v_manager_record
    FROM staff s
    JOIN staff_levels_junction slj ON s.id = slj.staff_id
    JOIN staff_levels sl ON slj.level_id = sl.id
    WHERE sl.name IN ('Director', 'C-Suite')
    AND slj.is_primary = true
    LIMIT 1;

    -- Insert completed evaluation
    INSERT INTO evaluation_responses (
      evaluation_id,
      staff_id,
      manager_id,
      self_ratings,
      self_comments,
      manager_ratings,
      manager_comments,
      percentage_score,
      status,
      submitted_at,
      completed_at
    ) VALUES (
      v_evaluation_id,
      v_staff_record.id,
      v_manager_record.id,
      '{
        "1": 5,
        "2": 4,
        "3": 5,
        "4": 4
      }',
      '{
        "1": "Exceeded annual targets",
        "2": "Significant career growth",
        "3": "Led major company initiatives",
        "4": "Developed strong team leadership",
        "overall": "Outstanding year with significant achievements"
      }',
      '{
        "1": 5,
        "2": 5,
        "3": 4,
        "4": 5
      }',
      '{
        "1": "Exceptional performance throughout the year",
        "2": "Demonstrated strong leadership growth",
        "3": "Significant contributions to company goals",
        "4": "Outstanding leadership qualities",
        "overall": "Exceptional performance and leadership"
      }',
      95.0,
      'completed',
      now() - interval '2 months',
      now() - interval '6 weeks'
    );
  END LOOP;
END $$;