/*
  # Fix Staff Levels RLS Policies

  1. Changes
    - Drop existing RLS policies
    - Create new policies that properly handle authentication
    - Ensure policies cover all CRUD operations
  
  2. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Allow authenticated users to read staff levels" ON staff_levels;
DROP POLICY IF EXISTS "Allow authenticated users to insert staff levels" ON staff_levels;
DROP POLICY IF EXISTS "Allow authenticated users to update staff levels" ON staff_levels;
DROP POLICY IF EXISTS "Allow authenticated users to delete staff levels" ON staff_levels;

-- Create new policies
CREATE POLICY "Enable read access for authenticated users"
ON staff_levels FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Enable insert access for authenticated users"
ON staff_levels FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Enable update access for authenticated users"
ON staff_levels FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

CREATE POLICY "Enable delete access for authenticated users"
ON staff_levels FOR DELETE
TO authenticated
USING (true);