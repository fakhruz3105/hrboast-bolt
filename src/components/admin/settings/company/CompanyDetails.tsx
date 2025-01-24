import React, { useState } from 'react';
import { Building2, Mail, Phone, MapPin, FileText, Save } from 'lucide-react';
import { supabase } from '../../../../lib/supabase';
import { toast } from 'react-hot-toast';

type CompanyDetailsProps = {
  initialData?: {
    name: string;
    ssm: string;
    address: string;
    phone: string;
    logo_url?: string;
  };
  onSave: (data: any) => Promise<void>;
};

export default function CompanyDetails({ initialData, onSave }: CompanyDetailsProps) {
  const [formData, setFormData] = useState({
    name: initialData?.name || '',
    ssm: initialData?.ssm || '',
    address: initialData?.address || '',
    phone: initialData?.phone || '',
    logo_url: initialData?.logo_url || ''
  });
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);

  const handleLogoChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file size (2MB limit)
    if (file.size > 2 * 1024 * 1024) {
      toast.error('Image size must be less than 2MB');
      return;
    }

    // Validate file type
    if (!file.type.startsWith('image/')) {
      toast.error('Only image files are allowed');
      return;
    }

    try {
      setUploading(true);

      // Upload to Supabase Storage
      const fileExt = file.name.split('.').pop();
      const fileName = `${crypto.randomUUID()}.${fileExt}`;
      const { error: uploadError, data } = await supabase.storage
        .from('company-logos')
        .upload(fileName, file);

      if (uploadError) throw uploadError;

      // Get public URL
      const { data: { publicUrl } } = supabase.storage
        .from('company-logos')
        .getPublicUrl(fileName);

      setFormData(prev => ({ ...prev, logo_url: publicUrl }));
      toast.success('Logo uploaded successfully');
    } catch (error) {
      console.error('Error uploading logo:', error);
      toast.error('Failed to upload logo');
    } finally {
      setUploading(false);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      await onSave(formData);
      toast.success('Company details saved successfully');
    } catch (error) {
      console.error('Error saving company details:', error);
      toast.error('Failed to save company details');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="bg-white rounded-lg shadow-sm p-6">
      <div className="flex justify-between items-center mb-6">
        <div>
          <h2 className="text-lg font-medium text-gray-900">Company Details</h2>
          <p className="mt-1 text-sm text-gray-500">
            These details will be used in formal letters and documents
          </p>
        </div>
        <button
          type="submit"
          form="company-details-form"
          disabled={loading || uploading}
          className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50"
        >
          <Save className="h-4 w-4 mr-2" />
          {loading ? 'Saving...' : 'Save Details'}
        </button>
      </div>

      <form id="company-details-form" onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          {/* Company Logo */}
          <div className="col-span-full">
            <label className="block text-sm font-medium text-gray-700">Company Logo</label>
            <div className="mt-1 flex items-center space-x-4">
              {formData.logo_url ? (
                <img 
                  src={formData.logo_url} 
                  alt="Company Logo" 
                  className="h-16 w-auto object-contain rounded-lg border border-gray-200"
                />
              ) : (
                <div className="h-16 w-16 rounded-lg border border-dashed border-gray-300 flex items-center justify-center">
                  <Building2 className="h-8 w-8 text-gray-400" />
                </div>
              )}
              <label className="relative cursor-pointer">
                <span className="px-4 py-2 text-sm text-indigo-600 hover:text-indigo-500">
                  {uploading ? 'Uploading...' : 'Change'}
                </span>
                <input
                  type="file"
                  className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                  accept="image/*"
                  onChange={handleLogoChange}
                  disabled={uploading}
                />
              </label>
            </div>
            <p className="mt-1 text-sm text-gray-500">
              Recommended size: 200x200px. Max file size: 2MB.
            </p>
          </div>

          {/* Company Name */}
          <div className="col-span-full">
            <label className="block text-sm font-medium text-gray-700">Company Name</label>
            <div className="mt-1 relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Building2 className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                required
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="e.g., Muslimtravelbug Sdn Bhd"
              />
            </div>
          </div>

          {/* SSM Number */}
          <div>
            <label className="block text-sm font-medium text-gray-700">SSM Number</label>
            <div className="mt-1 relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <FileText className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="text"
                required
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.ssm}
                onChange={(e) => setFormData({ ...formData, ssm: e.target.value })}
                placeholder="e.g., 1186376T"
              />
            </div>
          </div>

          {/* Phone Number */}
          <div>
            <label className="block text-sm font-medium text-gray-700">Phone Number</label>
            <div className="mt-1 relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Phone className="h-5 w-5 text-gray-400" />
              </div>
              <input
                type="tel"
                required
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.phone}
                onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                placeholder="e.g., 03 95441442"
              />
            </div>
          </div>

          {/* Address */}
          <div className="col-span-full">
            <label className="block text-sm font-medium text-gray-700">Address</label>
            <div className="mt-1 relative">
              <div className="absolute top-3 left-3 flex items-start pointer-events-none">
                <MapPin className="h-5 w-5 text-gray-400" />
              </div>
              <textarea
                required
                rows={3}
                className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={formData.address}
                onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                placeholder="e.g., 28-3 Jalan Equine 1D Taman Equine 43300 Seri Kembangan Selangor"
              />
            </div>
          </div>
        </div>
      </form>

      <div className="mt-6 pt-6 border-t border-gray-200">
        <div className="flex items-center space-x-2">
          <Building2 className="h-5 w-5 text-gray-400" />
          <p className="text-sm text-gray-500">
            These details will appear in the header and footer of all formal letters generated by the system.
          </p>
        </div>
      </div>
    </div>
  );
}