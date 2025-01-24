-- Drop existing table if exists
DROP TABLE IF EXISTS inventory_items CASCADE;

-- Create inventory items table
CREATE TABLE inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  item_type text NOT NULL CHECK (item_type IN ('Laptop', 'Phone', 'Tablet', 'Others')),
  item_name text NOT NULL,
  brand text NOT NULL,
  model text NOT NULL,
  serial_number text NOT NULL,
  purchase_date date,
  condition text NOT NULL CHECK (condition IN ('New', 'Used', 'Refurbished')),
  price numeric(10,2) NOT NULL CHECK (price >= 0),
  notes text,
  image_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes
CREATE INDEX idx_inventory_items_staff ON inventory_items(staff_id);
CREATE INDEX idx_inventory_items_type ON inventory_items(item_type);
CREATE INDEX idx_inventory_items_condition ON inventory_items(condition);

-- Enable RLS
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "inventory_items_select_policy_v2"
  ON inventory_items FOR SELECT
  USING (true);

CREATE POLICY "inventory_items_insert_policy_v2"
  ON inventory_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "inventory_items_update_policy_v2"
  ON inventory_items FOR UPDATE
  USING (true);

CREATE POLICY "inventory_items_delete_policy_v2"
  ON inventory_items FOR DELETE
  USING (true);

-- Create storage bucket for inventory images if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('inventory-images', 'inventory-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies if they exist
DROP POLICY IF EXISTS "inventory_images_select" ON storage.objects;
DROP POLICY IF EXISTS "inventory_images_insert" ON storage.objects;
DROP POLICY IF EXISTS "Allow public read access" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated insert access" ON storage.objects;

-- Create storage policies with unique names
CREATE POLICY "inventory_images_select_policy_v2"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_insert_policy_v2"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'inventory-images'
    AND auth.role() = 'authenticated'
  );