import React, { useState, useEffect } from 'react';
import { Plus, Search, Building2, Edit, Trash2 } from 'lucide-react';
import { toast } from 'react-hot-toast';
import { useSupabase } from '../../../providers/SupabaseProvider';

type Position = {
  id: string;
  title: string;
  description: string;
  department_id: string;
  requirements: string[];
  created_at: string;
  department: {
    name: string;
  };
};

export default function PositionsPage() {
  const supabase = useSupabase();
  const [positions, setPositions] = useState<Position[]>([]);
  const [departments, setDepartments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingPosition, setEditingPosition] = useState<Position | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedDepartment, setSelectedDepartment] = useState<string>('');
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    department_id: '',
    requirements: ['']
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      const [positionsResponse, departmentsResponse] = await Promise.all([
        supabase
          .from('positions')
          .select(`
            *,
            department:departments(name)
          `)
          .order('created_at', { ascending: false }),
        supabase
          .from('departments')
          .select('*')
          .order('name')
      ]);

      if (positionsResponse.error) throw positionsResponse.error;
      if (departmentsResponse.error) throw departmentsResponse.error;

      setPositions(positionsResponse.data || []);
      setDepartments(departmentsResponse.data || []);
    } catch (error) {
      console.error('Error loading data:', error);
      toast.error('Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const filteredRequirements = formData.requirements.filter(req => req.trim() !== '');
      
      if (editingPosition) {
        const { error } = await supabase
          .from('positions')
          .update({
            title: formData.title,
            description: formData.description,
            department_id: formData.department_id,
            requirements: filteredRequirements
          })
          .eq('id', editingPosition.id);

        if (error) throw error;
        toast.success('Position updated successfully');
      } else {
        const { error } = await supabase
          .from('positions')
          .insert([{
            title: formData.title,
            description: formData.description,
            department_id: formData.department_id,
            requirements: filteredRequirements
          }]);

        if (error) throw error;
        toast.success('Position created successfully');
      }

      setShowForm(false);
      setEditingPosition(null);
      setFormData({
        title: '',
        description: '',
        department_id: '',
        requirements: ['']
      });
      loadData();
    } catch (error) {
      console.error('Error saving position:', error);
      toast.error('Failed to save position');
    }
  };

  const handleDelete = async (id: string) => {
    if (!window.confirm('Are you sure you want to delete this position?')) return;

    try {
      const { error } = await supabase
        .from('positions')
        .delete()
        .eq('id', id);

      if (error) throw error;
      toast.success('Position deleted successfully');
      loadData();
    } catch (error) {
      console.error('Error deleting position:', error);
      toast.error('Failed to delete position');
    }
  };

  const addRequirement = () => {
    setFormData(prev => ({
      ...prev,
      requirements: [...prev.requirements, '']
    }));
  };

  const updateRequirement = (index: number, value: string) => {
    const newRequirements = [...formData.requirements];
    newRequirements[index] = value;
    setFormData(prev => ({
      ...prev,
      requirements: newRequirements
    }));
  };

  const removeRequirement = (index: number) => {
    setFormData(prev => ({
      ...prev,
      requirements: prev.requirements.filter((_, i) => i !== index)
    }));
  };

  const filteredPositions = positions.filter(position => {
    const matchesSearch = searchTerm === '' || 
      position.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      position.description.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesDepartment = selectedDepartment === '' || 
      position.department_id === selectedDepartment;
    
    return matchesSearch && matchesDepartment;
  });

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
          <h1 className="text-2xl font-bold text-gray-900">Staff Positions</h1>
          <p className="mt-1 text-sm text-gray-500">Manage staff positions and requirements</p>
        </div>
        <button
          onClick={() => {
            setEditingPosition(null);
            setFormData({
              title: '',
              description: '',
              department_id: '',
              requirements: ['']
            });
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
        >
          <Plus className="h-5 w-5 mr-2" />
          Create Position
        </button>
      </div>

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Search */}
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search positions..."
              className="pl-10 block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          {/* Department Filter */}
          <div>
            <select
              className="block w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedDepartment}
              onChange={(e) => setSelectedDepartment(e.target.value)}
            >
              <option value="">All Departments</option>
              {departments.map((dept) => (
                <option key={dept.id} value={dept.id}>{dept.name}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-lg p-6 max-w-2xl w-full">
            <h2 className="text-xl font-bold mb-4">
              {editingPosition ? 'Edit Position' : 'Create Position'}
            </h2>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700">Position Title</label>
                <input
                  type="text"
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Department</label>
                <select
                  required
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.department_id}
                  onChange={(e) => setFormData({ ...formData, department_id: e.target.value })}
                >
                  <option value="">Select Department</option>
                  {departments.map((dept) => (
                    <option key={dept.id} value={dept.id}>{dept.name}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700">Description</label>
                <textarea
                  required
                  rows={3}
                  className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Requirements</label>
                <div className="space-y-2">
                  {formData.requirements.map((req, index) => (
                    <div key={index} className="flex gap-2">
                      <input
                        type="text"
                        className="flex-1 rounded-md border border-gray-300 px-3 py-2"
                        value={req}
                        onChange={(e) => updateRequirement(index, e.target.value)}
                        placeholder={`Requirement ${index + 1}`}
                      />
                      <button
                        type="button"
                        onClick={() => removeRequirement(index)}
                        className="text-red-600 hover:text-red-800 p-2"
                      >
                        <Trash2 className="h-5 w-5" />
                      </button>
                    </div>
                  ))}
                  <button
                    type="button"
                    onClick={addRequirement}
                    className="text-sm text-indigo-600 hover:text-indigo-800"
                  >
                    + Add Requirement
                  </button>
                </div>
              </div>

              <div className="flex justify-end space-x-3 pt-4">
                <button
                  type="button"
                  onClick={() => {
                    setShowForm(false);
                    setEditingPosition(null);
                  }}
                  className="px-4 py-2 text-gray-700 hover:bg-gray-100 rounded-md"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700"
                >
                  {editingPosition ? 'Update Position' : 'Create Position'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Positions List */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Position</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Requirements</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredPositions.map((position) => (
                <tr key={position.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{position.title}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-500">{position.department?.name}</div>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm text-gray-500">{position.description}</div>
                  </td>
                  <td className="px-6 py-4">
                    <ul className="text-sm text-gray-500 list-disc list-inside">
                      {position.requirements.map((req, index) => (
                        <li key={index}>{req}</li>
                      ))}
                    </ul>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button
                      onClick={() => {
                        setEditingPosition(position);
                        setFormData({
                          title: position.title,
                          description: position.description,
                          department_id: position.department_id,
                          requirements: position.requirements
                        });
                        setShowForm(true);
                      }}
                      className="text-indigo-600 hover:text-indigo-900 mr-3"
                    >
                      <Edit className="h-4 w-4" />
                    </button>
                    <button
                      onClick={() => handleDelete(position.id)}
                      className="text-red-600 hover:text-red-900"
                    >
                      <Trash2 className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
              {filteredPositions.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-6 py-4 text-center text-sm text-gray-500">
                    No positions found
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}