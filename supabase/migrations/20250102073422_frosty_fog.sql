-- Update evaluation_forms table to use questions instead of criteria
ALTER TABLE evaluation_forms
DROP COLUMN criteria;

ALTER TABLE evaluation_forms
ADD COLUMN questions jsonb NOT NULL DEFAULT '[]',
ADD CONSTRAINT valid_questions CHECK (jsonb_typeof(questions) = 'array');

-- Update evaluation_responses to include percentage score
ALTER TABLE evaluation_responses
DROP COLUMN overall_rating;

ALTER TABLE evaluation_responses
ADD COLUMN percentage_score numeric(5,2) CHECK (percentage_score >= 0 AND percentage_score <= 100);

-- Function to calculate percentage score
CREATE OR REPLACE FUNCTION calculate_evaluation_percentage(
  manager_ratings jsonb,
  max_rating integer DEFAULT 5
) RETURNS numeric AS $$
DECLARE
  total_score numeric;
  max_possible_score numeric;
  num_ratings integer;
BEGIN
  -- Sum all ratings
  SELECT sum((value#>>'{}'::text[])::numeric)
  INTO total_score
  FROM jsonb_each(manager_ratings);

  -- Count number of ratings
  SELECT count(*)
  INTO num_ratings
  FROM jsonb_each(manager_ratings);

  -- Calculate max possible score
  max_possible_score := num_ratings * max_rating;

  -- Calculate percentage
  RETURN ROUND((total_score / max_possible_score * 100)::numeric, 2);
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically calculate percentage score
CREATE OR REPLACE FUNCTION update_evaluation_percentage()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.manager_ratings IS NOT NULL AND NEW.manager_ratings != '{}'::jsonb THEN
    NEW.percentage_score := calculate_evaluation_percentage(NEW.manager_ratings);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_percentage_score
  BEFORE INSERT OR UPDATE OF manager_ratings ON evaluation_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_evaluation_percentage();

-- Insert sample questions for different departments
WITH department_questions AS (
  SELECT
    departments.id as dept_id,
    departments.name as dept_name,
    CASE departments.name
      WHEN 'Engineering' THEN '[
        {
          "id": "1",
          "category": "Technical Skills",
          "question": "How well does the employee demonstrate technical proficiency in their role?",
          "description": "Consider code quality, problem-solving abilities, and technical knowledge"
        },
        {
          "id": "2",
          "category": "Project Delivery",
          "question": "How effectively does the employee manage and deliver projects?",
          "description": "Consider meeting deadlines, quality of deliverables, and project management skills"
        },
        {
          "id": "3",
          "category": "Innovation",
          "question": "How well does the employee contribute to technical innovation?",
          "description": "Consider new ideas, improvements to existing systems, and technical solutions"
        },
        {
          "id": "4",
          "category": "Collaboration",
          "question": "How effectively does the employee work with team members?",
          "description": "Consider communication, knowledge sharing, and team contributions"
        },
        {
          "id": "5",
          "category": "Documentation",
          "question": "How well does the employee maintain documentation?",
          "description": "Consider code comments, technical documentation, and knowledge base contributions"
        }
      ]'::jsonb
      WHEN 'Marketing' THEN '[
        {
          "id": "1",
          "category": "Campaign Performance",
          "question": "How successful are the employees marketing campaigns?",
          "description": "Consider ROI, reach, and engagement metrics"
        },
        {
          "id": "2",
          "category": "Creativity",
          "question": "How creative and innovative are their marketing solutions?",
          "description": "Consider unique approaches, creative concepts, and innovation"
        },
        {
          "id": "3",
          "category": "Analytics",
          "question": "How well do they utilize data and analytics?",
          "description": "Consider data analysis, insights generation, and data-driven decisions"
        },
        {
          "id": "4",
          "category": "Brand Management",
          "question": "How well do they maintain brand consistency?",
          "description": "Consider brand guidelines adherence and brand voice maintenance"
        },
        {
          "id": "5",
          "category": "Stakeholder Management",
          "question": "How effectively do they manage stakeholder relationships?",
          "description": "Consider communication with clients and internal stakeholders"
        }
      ]'::jsonb
      ELSE '[
        {
          "id": "1",
          "category": "Job Knowledge",
          "question": "How well does the employee understand their role and responsibilities?",
          "description": "Consider technical knowledge and role expertise"
        },
        {
          "id": "2",
          "category": "Quality of Work",
          "question": "How would you rate the quality of their work?",
          "description": "Consider accuracy, thoroughness, and attention to detail"
        },
        {
          "id": "3",
          "category": "Communication",
          "question": "How effective are their communication skills?",
          "description": "Consider verbal and written communication"
        },
        {
          "id": "4",
          "category": "Initiative",
          "question": "How well do they take initiative in their role?",
          "description": "Consider proactiveness and self-motivation"
        },
        {
          "id": "5",
          "category": "Teamwork",
          "question": "How well do they work with others?",
          "description": "Consider collaboration and team contributions"
        }
      ]'::jsonb
    END as questions
  FROM departments
)
UPDATE evaluation_forms
SET questions = dq.questions
FROM department_questions dq
WHERE evaluation_forms.department_id = dq.dept_id;