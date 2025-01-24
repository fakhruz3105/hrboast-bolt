-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "inventory_items_select" ON inventory_items;
  DROP POLICY IF EXISTS "inventory_items_insert" ON inventory_items;
  DROP POLICY IF EXISTS "inventory_items_update" ON inventory_items;
  DROP POLICY IF EXISTS "inventory_items_delete" ON inventory_items;
END $$;

-- Create RLS policies with unique names
CREATE POLICY "inventory_items_select_policy"
  ON inventory_items FOR SELECT
  USING (true);

CREATE POLICY "inventory_items_insert_policy"
  ON inventory_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "inventory_items_update_policy"
  ON inventory_items FOR UPDATE
  USING (true);

CREATE POLICY "inventory_items_delete_policy"
  ON inventory_items FOR DELETE
  USING (true);

-- Create storage bucket for inventory images if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('inventory-images', 'inventory-images')
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "inventory_images_select_policy" ON storage.objects;
  DROP POLICY IF EXISTS "inventory_images_insert_policy" ON storage.objects;
END $$;

-- Create new storage policies with unique names
CREATE POLICY "inventory_images_select_policy"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_insert_policy"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'inventory-images'
    AND auth.role() = 'authenticated'
  );