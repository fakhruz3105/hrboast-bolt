-- Drop all warning letter related functions
DROP FUNCTION IF EXISTS create_warning_letter CASCADE;
DROP FUNCTION IF EXISTS get_company_warning_letters CASCADE;
DROP FUNCTION IF EXISTS debug_warning_letters CASCADE;
DROP FUNCTION IF EXISTS upper(warning_level) CASCADE;

-- Drop warning letter table and related objects
DROP TABLE IF EXISTS warning_letters CASCADE;
DROP TYPE IF EXISTS warning_level CASCADE;

-- Clean up any orphaned HR letters related to warnings
DELETE FROM hr_letters 
WHERE type = 'warning';

-- Clean up any indexes
DROP INDEX IF EXISTS idx_warning_letters_company_staff;
DROP INDEX IF EXISTS idx_warning_letters_issued_date;
DROP INDEX IF EXISTS idx_warning_letters_company;
DROP INDEX IF EXISTS idx_warning_letters_staff;