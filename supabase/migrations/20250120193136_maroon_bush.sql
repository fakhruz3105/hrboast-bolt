-- Create storage bucket for company logos if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('company-logos', 'company-logos', true)
ON CONFLICT (id) DO UPDATE
SET public = true;

-- Create storage policies
DROP POLICY IF EXISTS "company_logos_select" ON storage.objects;
DROP POLICY IF EXISTS "company_logos_insert" ON storage.objects;
DROP POLICY IF EXISTS "company_logos_update" ON storage.objects;
DROP POLICY IF EXISTS "company_logos_delete" ON storage.objects;

CREATE POLICY "company_logos_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'company-logos');

CREATE POLICY "company_logos_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'company-logos');

CREATE POLICY "company_logos_update"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'company-logos');

CREATE POLICY "company_logos_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'company-logos');