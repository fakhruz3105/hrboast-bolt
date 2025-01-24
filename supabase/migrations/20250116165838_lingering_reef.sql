-- Drop existing policies
DROP POLICY IF EXISTS "staff_select" ON staff;
DROP POLICY IF EXISTS "benefits_select" ON benefits;
DROP POLICY IF EXISTS "evaluation_forms_select" ON evaluation_forms;
DROP POLICY IF EXISTS "warning_letters_select" ON warning_letters;
DROP POLICY IF EXISTS "hr_letters_select" ON hr_letters;
DROP POLICY IF EXISTS "memos_select" ON memos;

-- Create improved RLS policies with strict company isolation
CREATE POLICY "staff_select" ON staff
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all staff
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see staff from their own company
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "benefits_select" ON benefits
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all benefits
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see their company's benefits
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "evaluation_forms_select" ON evaluation_forms
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all evaluations
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see their company's evaluations
      company_id = (
        SELECT company_id FROM staff WHERE id = auth.uid()
      )
    )
  );

CREATE POLICY "warning_letters_select" ON warning_letters
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all warning letters
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see warning letters for their company's staff
      EXISTS (
        SELECT 1 FROM staff s
        WHERE s.id = warning_letters.staff_id
        AND s.company_id = (
          SELECT company_id FROM staff WHERE id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "hr_letters_select" ON hr_letters
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all HR letters
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see HR letters for their company's staff
      EXISTS (
        SELECT 1 FROM staff s
        WHERE s.id = hr_letters.staff_id
        AND s.company_id = (
          SELECT company_id FROM staff WHERE id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "memos_select" ON memos
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      -- Super admin can see all memos
      EXISTS (
        SELECT 1 FROM staff s
        JOIN role_mappings rm ON s.role_id = rm.id
        WHERE s.id = auth.uid() AND rm.role = 'super_admin'
      ) OR
      -- Company users can ONLY see memos for their company
      EXISTS (
        SELECT 1 FROM staff s
        WHERE s.id = auth.uid()
        AND (
          -- All staff memos for their company
          (memos.department_id IS NULL AND memos.staff_id IS NULL AND s.company_id = (
            SELECT company_id FROM staff WHERE id = memos.staff_id
          )) OR
          -- Department memos for their company's departments
          (memos.department_id IN (
            SELECT department_id FROM staff_departments 
            WHERE staff_id = s.id
          )) OR
          -- Personal memos
          memos.staff_id = s.id
        )
      )
    )
  );