import React, { useState, useEffect } from 'react';
import { Plus } from 'lucide-react';
import { useStaffProfile } from '../../../hooks/useStaffProfile';
import InventoryForm from '../../../components/admin/inventory/InventoryForm';
import InventoryList from '../../../components/admin/inventory/InventoryList';
import InventoryViewer from '../../../components/admin/inventory/InventoryViewer';
import { InventoryItem, InventoryFormData } from '../../../types/inventory';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function MyInventoryPage() {
  const supabase = useSupabase();
  const { staff } = useStaffProfile();
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState<InventoryItem | null>(null);
  const [viewingItem, setViewingItem] = useState<InventoryItem | null>(null);

  useEffect(() => {
    if (staff?.id) {
      loadInventory();
    }
  }, [staff?.id]);

  const loadInventory = async () => {
    if (!staff?.id) return;

    try {
      const { data, error } = await supabase
        .from('inventory_items')
        .select('*')
        .eq('staff_id', staff.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      setItems(data || []);
    } catch (error) {
      console.error('Error loading inventory:', error);
      toast.error('Failed to load inventory items');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (formData: InventoryFormData, _staffId: string, imageFile?: File) => {
    if (!staff?.id) return;

    try {
      let imageUrl = '';

      // Upload image if provided
      if (imageFile) {
        const fileExt = imageFile.name.split('.').pop();
        const fileName = `${crypto.randomUUID()}.${fileExt}`;
        const { error: uploadError, data } = await supabase.storage
          .from('inventory-images')
          .upload(fileName, imageFile);

        if (uploadError) throw uploadError;

        const { data: { publicUrl } } = supabase.storage
          .from('inventory-images')
          .getPublicUrl(fileName);

        imageUrl = publicUrl;
      }

      if (editingItem) {
        const { error } = await supabase
          .from('inventory_items')
          .update({
            ...formData,
            image_url: imageUrl || editingItem.image_url
          })
          .eq('id', editingItem.id)
          .eq('staff_id', staff.id);

        if (error) throw error;
        toast.success('Inventory item updated successfully');
      } else {
        const { error } = await supabase
          .from('inventory_items')
          .insert([{
            ...formData,
            staff_id: staff.id,
            image_url: imageUrl
          }]);

        if (error) throw error;
        toast.success('Inventory item added successfully');
      }

      setShowForm(false);
      setEditingItem(null);
      loadInventory();
    } catch (error) {
      console.error('Error saving inventory item:', error);
      toast.error('Failed to save inventory item');
    }
  };

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="space-y-4">
            <div className="h-12 bg-gray-200 rounded"></div>
            <div className="h-64 bg-gray-200 rounded"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!staff) {
    return (
      <div className="p-6">
        <div className="text-center py-12 bg-white rounded-lg shadow">
          <h3 className="mt-2 text-sm font-medium text-gray-900">Profile Not Found</h3>
          <p className="mt-1 text-sm text-gray-500">Unable to load your profile information.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Inventory</h1>
          <p className="text-gray-600 mt-1">Manage your office equipment and devices</p>
        </div>
        <button
          onClick={() => {
            setEditingItem(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Item
        </button>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <InventoryForm
            initialData={editingItem}
            onSubmit={handleSubmit}
            onCancel={() => {
              setShowForm(false);
              setEditingItem(null);
            }}
            isStaffView
          />
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <InventoryList
          items={items}
          onView={setViewingItem}
          onEdit={(item) => {
            setEditingItem(item);
            setShowForm(true);
          }}
          isStaffView
        />
      </div>

      {viewingItem && (
        <InventoryViewer
          item={viewingItem}
          onClose={() => setViewingItem(null)}
        />
      )}
    </div>
  );
}