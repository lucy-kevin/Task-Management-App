
import { BarChart3, Users, CheckCircle } from 'lucide-react';

const Sidebar = ({ currentPage, onPageChange, user, onLogout }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'users', label: 'Users', icon: Users },
    { id: 'tasks', label: 'Tasks', icon: CheckCircle },
    { id: 'analytics', label: 'Analytics', icon: BarChart3 }
  ];

  return (
    <div className="w-64 bg-gradient-to-b from-blue-600 to-blue-800 text-white flex flex-col shadow-xl">
      <div className="p-6 border-b border-blue-500 border-opacity-30">
        <h2 className="text-xl font-bold">Admin Panel</h2>
      </div>
      
      <nav className="flex-1 py-6">
        {menuItems.map((item) => {
          const Icon = item.icon;
          return (
            <button
              key={item.id}
              onClick={() => onPageChange(item.id)}
              className={`w-full flex items-center px-6 py-3 text-left hover:bg-blue-700 transition-colors ${
                currentPage === item.id ? 'bg-blue-700 border-r-4 border-white' : ''
              }`}
            >
              <Icon className="w-5 h-5 mr-3" />
              {item.label}
            </button>
          );
        })}
      </nav>

      <div className="p-6 border-t border-blue-500 border-opacity-30">
        <div className="flex items-center mb-4">
          <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center font-bold mr-3">
            {(user?.displayName || user?.email || 'U')[0].toUpperCase()}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">{user?.displayName || 'User'}</p>
            <p className="text-xs text-blue-200 truncate">{user?.email}</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="w-full bg-blue-700 hover:bg-blue-800 px-4 py-2 rounded text-sm transition-colors"
        >
          Sign Out
        </button>
      </div>
    </div>
  );
};
export default Sidebar;