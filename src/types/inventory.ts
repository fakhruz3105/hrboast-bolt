import { Staff } from './staff';

export type InventoryItem = {
  id: string;
  staff_id: string;
  item_type: 'Laptop' | 'Phone' | 'Tablet' | 'Others';
  item_name: string;
  brand: string;
  model: string;
  serial_number: string;
  purchase_date?: string;
  condition: 'New' | 'Used' | 'Refurbished';
  price: number;
  notes?: string;
  image_url?: string;
  created_at: string;
  updated_at: string;
  staff?: Staff;
};

export type InventoryFormData = Omit<InventoryItem, 'id' | 'staff_id' | 'created_at' | 'updated_at' | 'staff'>;