-- Drop existing policies
DROP POLICY IF EXISTS "inventory_items_select_policy_v5" ON inventory_items;
DROP POLICY IF EXISTS "inventory_items_insert_policy_v5" ON inventory_items;
DROP POLICY IF EXISTS "inventory_items_update_policy_v5" ON inventory_items;
DROP POLICY IF EXISTS "inventory_items_delete_policy_v5" ON inventory_items;

-- Create simplified RLS policies
CREATE POLICY "inventory_items_select_policy_v6"
  ON inventory_items FOR SELECT
  USING (true);

CREATE POLICY "inventory_items_insert_policy_v6"
  ON inventory_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "inventory_items_update_policy_v6"
  ON inventory_items FOR UPDATE
  USING (true);

CREATE POLICY "inventory_items_delete_policy_v6"
  ON inventory_items FOR DELETE
  USING (true);

-- Create storage policies with simplified access
CREATE POLICY "inventory_images_select_policy_v6"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_insert_policy_v6"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_update_policy_v6"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_delete_policy_v6"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'inventory-images');