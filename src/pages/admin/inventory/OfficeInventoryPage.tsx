import React, { useState, useEffect } from 'react';
import { Plus, Search } from 'lucide-react';
import { useStaff } from '../../../hooks/useStaff';
import InventoryList from '../../../components/admin/inventory/InventoryList';
import InventoryForm from '../../../components/admin/inventory/InventoryForm';
import InventoryViewer from '../../../components/admin/inventory/InventoryViewer';
import { InventoryItem, InventoryFormData } from '../../../types/inventory';
import { Staff } from '../../../types/staff';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

export default function OfficeInventoryPage() {
  const supabase = useSupabase();
  const { staff } = useStaff();
  const [items, setItems] = useState<InventoryItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingItem, setEditingItem] = useState<InventoryItem | null>(null);
  const [viewingItem, setViewingItem] = useState<InventoryItem | null>(null);
  const [selectedStaffId, setSelectedStaffId] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadInventory();
  }, [selectedStaffId]);

  const loadInventory = async () => {
    try {
      let query = supabase
        .from('inventory_items')
        .select(`
          *,
          staff:staff_id (
            name,
            departments:staff_departments(
              is_primary,
              department:departments(name)
            )
          )
        `)
        .order('created_at', { ascending: false });

      if (selectedStaffId) {
        query = query.eq('staff_id', selectedStaffId);
      }

      const { data, error } = await query;

      if (error) throw error;
      setItems(data || []);
    } catch (error) {
      console.error('Error loading inventory:', error);
      toast.error('Failed to load inventory items');
    } finally {
      setLoading(false);
    }
  };

  // Calculate summary statistics
  const summary = {
    phones: items.filter(item => item.item_type === 'Phone').length,
    tablets: items.filter(item => item.item_type === 'Tablet').length,
    laptops: items.filter(item => item.item_type === 'Laptop').length,
    others: items.filter(item => item.item_type === 'Others').length,
    totalValue: items.reduce((sum, item) => sum + item.price, 0)
  };

  // Filter staff based on search term
  const filteredStaff = staff.filter(member => 
    member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    member.departments?.[0]?.department?.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSubmit = async (formData: InventoryFormData, staffId: string, imageFile?: File) => {
    try {
      let imageUrl = '';

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
          .eq('id', editingItem.id);

        if (error) throw error;
        toast.success('Inventory item updated successfully');
      } else {
        const { error } = await supabase
          .from('inventory_items')
          .insert([{
            ...formData,
            staff_id: staffId,
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

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this inventory item?')) {
      return;
    }

    try {
      const { error } = await supabase
        .from('inventory_items')
        .delete()
        .eq('id', id);

      if (error) throw error;
      toast.success('Inventory item deleted successfully');
      loadInventory();
    } catch (error) {
      console.error('Error deleting inventory item:', error);
      toast.error('Failed to delete inventory item');
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

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Office Inventory</h1>
          <p className="text-gray-600 mt-1">Manage office equipment and devices</p>
        </div>
        <button
          onClick={() => {
            setEditingItem(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Inventory Item
        </button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-500">Phones</h3>
          <p className="mt-1 text-2xl font-semibold text-gray-900">{summary.phones}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-500">Tablets</h3>
          <p className="mt-1 text-2xl font-semibold text-gray-900">{summary.tablets}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-500">Laptops</h3>
          <p className="mt-1 text-2xl font-semibold text-gray-900">{summary.laptops}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-500">Others</h3>
          <p className="mt-1 text-2xl font-semibold text-gray-900">{summary.others}</p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-sm font-medium text-gray-500">Total Value</h3>
          <p className="mt-1 text-2xl font-semibold text-gray-900">RM {summary.totalValue.toFixed(2)}</p>
        </div>
      </div>

      {/* Staff Filter with Search */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">Filter by Staff</label>
        <div className="relative">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search className="h-5 w-5 text-gray-400" />
          </div>
          <input
            type="text"
            placeholder="Search staff by name or department..."
            className="pl-10 block w-full rounded-md border border-gray-300 px-3 py-2 mb-2"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <select
          className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
          value={selectedStaffId}
          onChange={(e) => setSelectedStaffId(e.target.value)}
        >
          <option value="">All Staff</option>
          {filteredStaff.map((member) => (
            <option key={member.id} value={member.id}>
              {member.name} - {member.departments?.[0]?.department?.name}
            </option>
          ))}
        </select>
      </div>

      {showForm && (
        <div className="bg-white p-6 rounded-lg shadow mb-6">
          <InventoryForm
            staff={staff}
            initialData={editingItem}
            onSubmit={handleSubmit}
            onCancel={() => {
              setShowForm(false);
              setEditingItem(null);
            }}
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
          onDelete={handleDelete}
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