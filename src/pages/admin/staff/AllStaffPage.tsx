import React, { useState } from 'react';
import { Plus, Search, Filter, Users, Building2, CheckCircle, Clock } from 'lucide-react';
import { Staff } from '../../../types/staff';
import StaffList from '../../../components/admin/staff/StaffList';
import StaffForm from '../../../components/admin/staff/StaffForm';
import { useStaff } from '../../../hooks/useStaff';
import { useDepartments } from '../../../hooks/useDepartments';
import { useStaffLevels } from '../../../hooks/useStaffLevels';

export default function AllStaffPage() {
  const { staff, loading: staffLoading, error: staffError, addStaff, updateStaff, deleteStaff } = useStaff();
  const { departments, loading: deptLoading } = useDepartments();
  const { levels, loading: levelsLoading } = useStaffLevels();
  const [showForm, setShowForm] = useState(false);
  const [editingStaff, setEditingStaff] = useState<Staff | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedDepartment, setSelectedDepartment] = useState<string>('');
  const [selectedLevel, setSelectedLevel] = useState<string>('');
  const [selectedStatus, setSelectedStatus] = useState<string>('');

  const loading = staffLoading || deptLoading || levelsLoading;

  // Calculate statistics
  const stats = {
    totalStaff: staff.length,
    totalDepartments: new Set(staff.flatMap(s => s.departments?.map(d => d.department_id) || [])).size,
    totalPermanent: staff.filter(s => s.status === 'permanent').length,
    totalProbation: staff.filter(s => s.status === 'probation').length
  };

  const handleSubmit = async (formData: any) => {
    try {
      if (editingStaff) {
        await updateStaff(editingStaff.id, formData);
      } else {
        await addStaff(formData);
      }
      setShowForm(false);
      setEditingStaff(null);
    } catch (err) {
      console.error('Error saving staff:', err);
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

  if (staffError) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-600 p-4 rounded-lg">
          Error: {staffError.message}
        </div>
      </div>
    );
  }

  // Filter staff based on search and filters
  const filteredStaff = staff.filter(member => {
    const matchesSearch = 
      member.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      member.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      member.phone_number.includes(searchTerm);

    const matchesDepartment = !selectedDepartment || 
      member.departments?.some(d => d.department_id === selectedDepartment);

    const matchesLevel = !selectedLevel || member.level_id === selectedLevel;
    const matchesStatus = !selectedStatus || member.status === selectedStatus;

    return matchesSearch && matchesDepartment && matchesLevel && matchesStatus;
  });

  return (
    <div className="p-6">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">All Staff</h1>
          <p className="text-sm text-gray-500 mt-1">Manage staff members and their information</p>
        </div>
        <button
          onClick={() => {
            setEditingStaff(null);
            setShowForm(true);
          }}
          className="inline-flex items-center px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 whitespace-nowrap"
        >
          <Plus className="h-5 w-5 mr-2" />
          Add Staff Member
        </button>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex items-center">
            <Users className="h-8 w-8 text-indigo-600" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Total Staff</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.totalStaff}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex items-center">
            <Building2 className="h-8 w-8 text-blue-600" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Departments</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.totalDepartments}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex items-center">
            <CheckCircle className="h-8 w-8 text-green-600" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Permanent</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.totalPermanent}</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-4 rounded-lg shadow-sm">
          <div className="flex items-center">
            <Clock className="h-8 w-8 text-yellow-600" />
            <div className="ml-4">
              <p className="text-sm font-medium text-gray-500">Probation</p>
              <p className="text-2xl font-semibold text-gray-900">{stats.totalProbation}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Search and Filters */}
      <div className="bg-white p-4 rounded-lg shadow-sm mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4">
          {/* Search */}
          <div className="lg:col-span-2">
            <div className="relative">
              <Search className="h-5 w-5 absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
              <input
                type="text"
                placeholder="Search by name, email, or phone..."
                className="pl-10 w-full rounded-md border border-gray-300 px-4 py-2 focus:ring-indigo-500 focus:border-indigo-500"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
          </div>

          {/* Department Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedDepartment}
              onChange={(e) => setSelectedDepartment(e.target.value)}
            >
              <option value="">All Departments</option>
              {departments.map((dept) => (
                <option key={dept.id} value={dept.id}>{dept.name}</option>
              ))}
            </select>
          </div>

          {/* Level Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedLevel}
              onChange={(e) => setSelectedLevel(e.target.value)}
            >
              <option value="">All Levels</option>
              {levels.map((level) => (
                <option key={level.id} value={level.id}>{level.name}</option>
              ))}
            </select>
          </div>

          {/* Status Filter */}
          <div>
            <select
              className="w-full rounded-md border border-gray-300 px-3 py-2 focus:ring-indigo-500 focus:border-indigo-500"
              value={selectedStatus}
              onChange={(e) => setSelectedStatus(e.target.value)}
            >
              <option value="">All Status</option>
              <option value="permanent">Permanent</option>
              <option value="probation">Probation</option>
              <option value="resigned">Resigned</option>
            </select>
          </div>
        </div>
      </div>

      {showForm && (
        <div className="fixed inset-0 bg-black/50 z-50 overflow-y-auto">
          <div className="min-h-screen px-4 py-8">
            <div className="relative bg-white max-w-2xl mx-auto rounded-xl shadow-lg">
              <div className="p-6">
                <h2 className="text-lg font-semibold mb-4">
                  {editingStaff ? 'Edit Staff Member' : 'Add Staff Member'}
                </h2>
                <StaffForm
                  initialData={editingStaff}
                  departments={departments}
                  levels={levels}
                  onSubmit={handleSubmit}
                  onCancel={() => {
                    setShowForm(false);
                    setEditingStaff(null);
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow">
        <StaffList
          staff={filteredStaff}
          onEdit={(member) => {
            setEditingStaff(member);
            setShowForm(true);
          }}
          onDelete={deleteStaff}
        />
      </div>

      {/* Results Summary */}
      <div className="mt-4 text-sm text-gray-500">
        Showing {filteredStaff.length} of {staff.length} staff members
      </div>
    </div>
  );
}