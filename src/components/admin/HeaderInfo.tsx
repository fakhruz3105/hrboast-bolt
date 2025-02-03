import { Building2, User } from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

export default function HeaderInfo() {
  const { user, company: companyName } = useAuth();

  if (!companyName && !user) return null;

  return (
    <div className="bg-white border-b border-gray-200 fixed top-0 right-0 left-0 z-[40] lg:left-64">
      <div className="h-16 px-4 flex items-center">
        {/* Mobile Menu Space - Left */}
        <div className="w-10 lg:hidden"></div>

        {/* Content - Center/Right */}
        <div className="flex-1 flex items-center justify-end">
          <div className="flex items-center space-x-4">
            {/* Company Name - Hidden on mobile */}
            {companyName && (
              <div className="hidden md:flex items-center text-gray-600">
                <Building2 className="h-4 w-4 mr-1 flex-shrink-0" />
                <span className="text-sm font-medium truncate">{companyName}</span>
              </div>
            )}

            {/* Separator - Hidden on mobile */}
            <span className="hidden md:block text-gray-300">|</span>

            {/* Staff Name - Always visible */}
            {user?.name && (
              <div className="flex items-center text-gray-600">
                <User className="h-4 w-4 mr-1 flex-shrink-0" />
                <span className="text-sm font-medium truncate max-w-[120px] md:max-w-none">
                  {user.name}
                </span>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}