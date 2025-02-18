import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { 
  Menu, X, LayoutDashboard, Users, Building2, Layers, 
  FileSpreadsheet, ClipboardCheck, UserMinus, AlertTriangle, 
  Settings, Shield, FileText, Gift, LogOut, Mail, UserCircle,
  Target, Calendar, Database, Key, Monitor, Clock, Briefcase
} from 'lucide-react';
import { useAuth } from '../../contexts/AuthContext';

type MenuItem = {
  icon: React.ElementType;
  label: string;
  path: string;
  submenu?: MenuItem[];
  roles?: string[];
};

type MenuItemProps = {
  item: MenuItem;
  isSubmenu?: boolean;
};

const MenuItem = ({ item, isSubmenu = false }: MenuItemProps) => {
  const location = useLocation();
  const isActive = location.pathname === item.path || 
                  (item.submenu && item.submenu.some(sub => location.pathname === sub.path));
  const hasSubmenu = item.submenu && item.submenu.length > 0;
  const [isOpen, setIsOpen] = useState(isActive);

  return (
    <div>
      <Link
        to={hasSubmenu ? '#' : item.path}
        className={`flex items-center px-4 py-2 text-sm font-medium rounded-lg ${
          isActive 
            ? 'bg-indigo-50 text-indigo-600' 
            : 'text-gray-600 hover:bg-indigo-50 hover:text-indigo-600'
        } ${isSubmenu ? 'pl-8' : ''}`}
        onClick={(e) => {
          if (hasSubmenu) {
            e.preventDefault();
            setIsOpen(!isOpen);
          }
        }}
      >
        <item.icon className="h-5 w-5 mr-2" />
        <span>{item.label}</span>
        {hasSubmenu && (
          <svg
            className={`w-4 h-4 ml-auto transition-transform ${isOpen ? 'rotate-180' : ''}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        )}
      </Link>
      {hasSubmenu && isOpen && (
        <div className="ml-4 mt-1">
          {item.submenu!.map((subItem, index) => (
            <MenuItem key={index} item={subItem} isSubmenu={true} />
          ))}
        </div>
      )}
    </div>
  );
};

const superAdminMenuItems: MenuItem[] = [
  {
    icon: LayoutDashboard,
    label: 'Dashboard',
    path: '/admin/dashboard/super',
    roles: ['super_admin']
  },
  {
    icon: Building2,
    label: 'Companies',
    path: '/admin/settings/companies',
    roles: ['super_admin']
  },
  {
    icon: Key,
    label: 'The Master',
    path: '/admin/settings/master',
    roles: ['super_admin']
  }
];

const adminMenuItems: MenuItem[] = [
  { 
    icon: LayoutDashboard,
    label: 'Dashboard',
    path: '/admin/dashboard',
    roles: ['admin', 'hr']
  },
  {
    icon: Target,
    label: 'Staff KPI',
    path: '/admin/staff-kpi',
    roles: ['admin', 'hr']
  },
  {
    icon: Users,
    label: 'Staff Directory',
    path: '/admin/staff',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: Users, label: 'All Staff', path: '/admin/staff/all' },
      { icon: Clock, label: 'Probation Staff', path: '/admin/staff/probation' },
      { icon: Building2, label: 'Departments', path: '/admin/staff/departments' },
      { icon: Layers, label: 'Staff Levels', path: '/admin/staff/levels' },
      { icon: Briefcase, label: 'Staff Positions', path: '/admin/staff/positions' }
    ]
  },
  {
    icon: Calendar,
    label: 'Company Events',
    path: '/admin/events',
    roles: ['admin', 'hr']
  },
  {
    icon: FileSpreadsheet,
    label: 'Evaluation',
    path: '/admin/evaluation',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: ClipboardCheck, label: 'Create Form', path: '/admin/evaluation/create' },
      { icon: FileSpreadsheet, label: 'Evaluation List', path: '/admin/evaluation/list/quarter' }
    ]
  },
  {
    icon: FileText,
    label: 'HR Form',
    path: '/admin/hr-form',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: Users, label: 'Employee Form', path: '/admin/hr-form/employee-form' },
      { icon: UserMinus, label: 'Exit Interview Form', path: '/admin/hr-form/exit-interview' }
    ]
  },
  {
    icon: Mail,
    label: 'Achievement Memo',
    path: '/admin/hr-form/memo',
    roles: ['admin', 'hr']
  },
  {
    icon: AlertTriangle,
    label: 'Miss Conduct',
    path: '/admin/misconduct',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: AlertTriangle, label: 'Warning Letter', path: '/admin/misconduct/warning' },
      { icon: AlertTriangle, label: 'Show Cause', path: '/admin/misconduct/show-cause' }
    ]
  },
  {
    icon: Gift,
    label: 'Benefits',
    path: '/admin/benefits',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: Gift, label: 'Manage Benefits', path: '/admin/benefits/manage' }
    ]
  },
  {
    icon: Monitor,
    label: 'Inventory',
    path: '/admin/inventory',
    roles: ['admin', 'hr'],
    submenu: [
      { icon: Monitor, label: 'Office Inventory', path: '/admin/inventory/manage' }
    ]
  },
  {
    icon: Settings,
    label: 'Settings',
    path: '/admin/settings',
    roles: ['admin'],
    submenu: [
      { icon: Building2, label: 'My Company', path: '/admin/settings/my-company' },
      { icon: Users, label: 'Users', path: '/admin/settings/users' },
      { icon: Shield, label: 'Roles', path: '/admin/settings/roles' }
    ]
  }
];

const staffMenuItems: MenuItem[] = [
  {
    icon: LayoutDashboard,
    label: 'My Dashboard',
    path: '/admin/staff-view/dashboard'
  },
  {
    icon: Target,
    label: 'My KPI',
    path: '/admin/staff-view/kpi'
  },
  {
    icon: Calendar,
    label: 'My Company Events',
    path: '/admin/staff-view/events'
  },
  {
    icon: FileText,
    label: 'Letter from HR',
    path: '/admin/staff-view/letters'
  },
  {
    icon: Mail,
    label: 'My Achievement',
    path: '/admin/staff-view/memo'
  },
  {
    icon: FileSpreadsheet,
    label: 'My Evaluations',
    path: '/admin/staff-view/evaluations'
  },
  {
    icon: Gift,
    label: 'My Benefits',
    path: '/admin/staff-view/benefits'
  },
  {
    icon: Monitor,
    label: 'My Inventory',
    path: '/admin/staff-view/inventory'
  },
  {
    icon: UserCircle,
    label: 'My Profile',
    path: '/admin/staff-view/profile'
  }
];

export default function Sidebar({ userRole }: { userRole: string }) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  // Get appropriate menu items based on role
  const menuItems = userRole === 'super_admin' 
    ? superAdminMenuItems 
    : adminMenuItems.filter(item => !item.roles || item.roles.includes(userRole));

  return (
    <>
      {/* Mobile Menu Button - Fixed position with highest z-index */}
      <div className="lg:hidden fixed top-0 left-0 w-10 h-16 flex items-center justify-center z-[60]">
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 rounded-md text-gray-600 hover:bg-gray-100"
        >
          {isMobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
        </button>
      </div>

      {/* Mobile Menu Overlay - Full screen with high z-index */}
      {isMobileMenuOpen && (
        <div 
          className="lg:hidden fixed inset-0 bg-black/50 z-[55]" 
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar - Higher z-index than overlay but lower than button */}
      <aside className={`
        fixed top-0 left-0 h-screen bg-white border-r border-gray-200 z-[58]
        transform transition-transform duration-300 ease-in-out
        w-64 lg:translate-x-0 pt-16 lg:pt-4
        ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}
      `}>
        <div className="h-full overflow-y-auto">
          <div className="px-4">
            <h1 className="text-xl font-bold text-gray-800 mb-6 hidden lg:block">HR Portal</h1>
            <nav className="space-y-1">
              {/* Super Admin View */}
              {userRole === 'super_admin' && (
                <>
                  <div className="mb-2">
                    <h2 className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Super Admin
                    </h2>
                  </div>
                  {superAdminMenuItems.map((item, index) => (
                    <MenuItem key={index} item={item} />
                  ))}
                  <div className="my-4 border-t border-gray-200" />
                </>
              )}

              {/* Admin View */}
              {(userRole === 'admin' || userRole === 'hr') && (
                <>
                  <div className="mb-2">
                    <h2 className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Admin View
                    </h2>
                  </div>
                  {menuItems.map((item, index) => (
                    <MenuItem key={index} item={item} />
                  ))}
                  <div className="my-4 border-t border-gray-200" />
                </>
              )}

              {/* Staff View */}
              {userRole !== 'super_admin' && (
                <>
                  <div className="mb-2">
                    <h2 className="px-4 text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Staff View
                    </h2>
                  </div>
                  {staffMenuItems.map((item, index) => (
                    <MenuItem key={`staff-${index}`} item={item} />
                  ))}
                </>
              )}

              {/* Logout Button */}
              <div className="mt-4 border-t border-gray-200 pt-4">
                <button
                  onClick={handleLogout}
                  className="flex items-center w-full px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg"
                >
                  <LogOut className="h-5 w-5 mr-2" />
                  Logout
                </button>
              </div>
            </nav>
          </div>
        </div>
      </aside>
    </>
  );
}