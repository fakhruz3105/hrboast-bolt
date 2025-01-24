-- Create evaluation type enum
CREATE TYPE evaluation_type AS ENUM ('quarter', 'half-year', 'yearly');
CREATE TYPE evaluation_status AS ENUM ('pending', 'completed');

-- Create evaluation forms table
CREATE TABLE evaluation_forms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  type evaluation_type NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE RESTRICT,
  level_id uuid REFERENCES staff_levels(id) ON DELETE RESTRICT,
  criteria jsonb NOT NULL DEFAULT '[]',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_criteria CHECK (jsonb_typeof(criteria) = 'array')
);

-- Create evaluation responses table
CREATE TABLE evaluation_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  evaluation_id uuid REFERENCES evaluation_forms(id) ON DELETE RESTRICT,
  staff_id uuid REFERENCES staff(id) ON DELETE RESTRICT,
  manager_id uuid REFERENCES staff(id) ON DELETE RESTRICT,
  self_ratings jsonb NOT NULL DEFAULT '{}',
  self_comments jsonb NOT NULL DEFAULT '{}',
  manager_ratings jsonb NOT NULL DEFAULT '{}',
  manager_comments jsonb NOT NULL DEFAULT '{}',
  overall_rating numeric(3,2) CHECK (overall_rating >= 0 AND overall_rating <= 5),
  status evaluation_status NOT NULL DEFAULT 'pending',
  submitted_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT valid_ratings CHECK (
    jsonb_typeof(self_ratings) = 'object' AND
    jsonb_typeof(self_comments) = 'object' AND
    jsonb_typeof(manager_ratings) = 'object' AND
    jsonb_typeof(manager_comments) = 'object'
  )
);

-- Create indexes
CREATE INDEX idx_evaluation_forms_type ON evaluation_forms(type);
CREATE INDEX idx_evaluation_forms_department ON evaluation_forms(department_id);
CREATE INDEX idx_evaluation_forms_level ON evaluation_forms(level_id);

CREATE INDEX idx_evaluation_responses_evaluation ON evaluation_responses(evaluation_id);
CREATE INDEX idx_evaluation_responses_staff ON evaluation_responses(staff_id);
CREATE INDEX idx_evaluation_responses_manager ON evaluation_responses(manager_id);
CREATE INDEX idx_evaluation_responses_status ON evaluation_responses(status);

-- Enable RLS
ALTER TABLE evaluation_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for evaluation forms
CREATE POLICY "Enable read access for all users on evaluation_forms"
  ON evaluation_forms FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users on evaluation_forms"
  ON evaluation_forms FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users on evaluation_forms"
  ON evaluation_forms FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create RLS policies for evaluation responses
CREATE POLICY "Enable read access for all users on evaluation_responses"
  ON evaluation_responses FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users on evaluation_responses"
  ON evaluation_responses FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users on evaluation_responses"
  ON evaluation_responses FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- Create trigger for updated_at
CREATE TRIGGER set_evaluation_forms_updated_at
  BEFORE UPDATE ON evaluation_forms
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_evaluation_responses_updated_at
  BEFORE UPDATE ON evaluation_responses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample evaluation forms
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
      'Q1 2024 Engineering Performance Review',
      'quarter',
      'Engineering',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Technical Skills",
          "title": "Code Quality",
          "description": "Ability to write clean, maintainable code",
          "weight": 30
        },
        {
          "id": "2",
          "category": "Productivity",
          "title": "Project Delivery",
          "description": "Ability to deliver projects on time",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Soft Skills",
          "title": "Communication",
          "description": "Effectiveness in team communication",
          "weight": 20
        },
        {
          "id": "4",
          "category": "Leadership",
          "title": "Initiative",
          "description": "Taking initiative in projects and tasks",
          "weight": 20
        }
      ]'
    ),
    (
      'H1 2024 Marketing Team Evaluation',
      'half-year',
      'Marketing',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Performance",
          "title": "Campaign Success",
          "description": "Success rate of marketing campaigns",
          "weight": 40
        },
        {
          "id": "2",
          "category": "Creativity",
          "title": "Innovation",
          "description": "Ability to bring creative solutions",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Analytics",
          "title": "Data Analysis",
          "description": "Ability to analyze and use data effectively",
          "weight": 30
        }
      ]'
    ),
    (
      '2024 Annual Sales Performance Review',
      'yearly',
      'Sales',
      'Staff',
      '[
        {
          "id": "1",
          "category": "Sales Performance",
          "title": "Target Achievement",
          "description": "Achievement of sales targets",
          "weight": 40
        },
        {
          "id": "2",
          "category": "Client Relations",
          "title": "Client Satisfaction",
          "description": "Maintaining positive client relationships",
          "weight": 30
        },
        {
          "id": "3",
          "category": "Team Work",
          "title": "Collaboration",
          "description": "Ability to work effectively with team",
          "weight": 30
        }
      ]'
    )
) AS data(title, type, department_name, level_name, criteria)
JOIN departments ON departments.name = data.department_name
JOIN staff_levels ON staff_levels.name = data.level_name;