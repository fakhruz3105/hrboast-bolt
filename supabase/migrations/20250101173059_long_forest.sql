/*
  # Update staff table schema

  1. Changes
    - Remove first_name and last_name, replace with single name field
    - Add phone_number field
    - Add status field with enum type
    - Remove unused fields
*/

-- Create enum for staff status
CREATE TYPE staff_status AS ENUM ('permanent', 'probation', 'resigned');

-- Update staff table
ALTER TABLE staff 
  -- Drop existing columns
  DROP COLUMN first_name,
  DROP COLUMN last_name,
  -- Add new columns
  ADD COLUMN name text NOT NULL,
  ADD COLUMN phone_number text NOT NULL,
  ADD COLUMN status staff_status NOT NULL DEFAULT 'probation';