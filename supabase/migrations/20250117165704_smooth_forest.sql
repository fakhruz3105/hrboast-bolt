-- Create inventory items table
CREATE TABLE inventory_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  staff_id uuid REFERENCES staff(id) ON DELETE CASCADE,
  item_type text NOT NULL CHECK (item_type IN ('laptop', 'phone', 'tablet', 'monitor', 'other')),
  item_name text NOT NULL,
  brand text NOT NULL,
  model text NOT NULL,
  serial_number text NOT NULL,
  purchase_date date,
  condition text NOT NULL CHECK (condition IN ('new', 'good', 'fair', 'poor')),
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
CREATE POLICY "inventory_items_select"
  ON inventory_items FOR SELECT
  USING (true);

CREATE POLICY "inventory_items_insert"
  ON inventory_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "inventory_items_update"
  ON inventory_items FOR UPDATE
  USING (true);

CREATE POLICY "inventory_items_delete"
  ON inventory_items FOR DELETE
  USING (true);

-- Create storage bucket for inventory images if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('inventory-images', 'inventory-images')
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies with unique names
CREATE POLICY "inventory_images_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'inventory-images');

CREATE POLICY "inventory_images_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'inventory-images'
    AND auth.role() = 'authenticated'
  );