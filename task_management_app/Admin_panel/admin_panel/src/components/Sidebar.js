import React from 'react';
import { BarChart3, Users, CheckCircle } from 'lucide-react';

const Sidebar = ({ currentPage, onPageChange, user, onLogout }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: BarChart3 },
    { id: 'users', label: 'Users', icon: Users },
    { id: 'tasks', label: 'Tasks', icon: CheckCircle },
    { id: 'analytics', label: 'Analytics', icon: BarChart3 }
  ];

  const styles = {
    sidebar: {
      width: '16rem',
      backgroundColor: '#1e40af',
      color: 'white',
      display: 'flex',
      flexDirection: 'column',
      boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
      height: '100vh',
      position: 'relative'
    },
    header: {
      padding: '1.5rem',
      borderBottom: '1px solid rgba(59, 130, 246, 0.3)',
      backgroundColor: '#1d4ed8'
    },
    headerTitle: {
      fontSize: '1.25rem',
      fontWeight: 'bold',
      margin: '0',
      color: 'white'
    },
    nav: {
      flex: '1',
      paddingTop: '1.5rem',
      paddingBottom: '1.5rem'
    },
    menuButton: {
      width: '100%',
      display: 'flex',
      alignItems: 'center',
      padding: '0.75rem 1.5rem',
      textAlign: 'left',
      backgroundColor: 'transparent',
      border: 'none',
      color: 'white',
      cursor: 'pointer',
      transition: 'all 0.3s ease',
      fontSize: '0.875rem',
      fontWeight: '500',
      position: 'relative'
    },
    menuButtonHover: {
      backgroundColor: '#2563eb',
      transform: 'translateX(4px)'
    },
    menuButtonActive: {
      backgroundColor: '#2563eb',
      borderRight: '4px solid white',
      fontWeight: '600'
    },
    menuIcon: {
      width: '1.25rem',
      height: '1.25rem',
      marginRight: '0.75rem',
      transition: 'transform 0.3s ease'
    },
    menuIconActive: {
      transform: 'scale(1.1)'
    },
    footer: {
      padding: '1.5rem',
      borderTop: '1px solid rgba(59, 130, 246, 0.3)',
      backgroundColor: '#1d4ed8'
    },
    userInfo: {
      display: 'flex',
      alignItems: 'center',
      marginBottom: '1rem'
    },
    avatar: {
      width: '2.5rem',
      height: '2.5rem',
      backgroundColor: '#3b82f6',
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontWeight: 'bold',
      marginRight: '0.75rem',
      fontSize: '1rem',
      border: '2px solid white',
      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
    },
    userDetails: {
      flex: '1',
      minWidth: '0'
    },
    userName: {
      fontSize: '0.875rem',
      fontWeight: '500',
      margin: '0',
      color: 'white',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    },
    userEmail: {
      fontSize: '0.75rem',
      margin: '0',
      color: '#93c5fd',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    },
    logoutButton: {
      width: '100%',
      backgroundColor: '#2563eb',
      color: 'white',
      padding: '0.75rem 1rem',
      borderRadius: '0.5rem',
      fontSize: '0.875rem',
      fontWeight: '500',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.3s ease',
      boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)'
    },
    logoutButtonHover: {
      backgroundColor: '#1d4ed8',
      transform: 'translateY(-1px)',
      boxShadow: '0 4px 6px rgba(0, 0, 0, 0.15)'
    }
  };

  return (
    <div style={styles.sidebar}>
      <div style={styles.header}>
        <h2 style={styles.headerTitle}>Admin Panel</h2>
      </div>
      
      <nav style={styles.nav}>
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentPage === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => onPageChange(item.id)}
              style={{
                ...styles.menuButton,
                ...(isActive ? styles.menuButtonActive : {})
              }}
              onMouseEnter={(e) => {
                if (!isActive) {
                  Object.assign(e.currentTarget.style, styles.menuButtonHover);
                }
              }}
              onMouseLeave={(e) => {
                if (!isActive) {
                  e.currentTarget.style.backgroundColor = 'transparent';
                  e.currentTarget.style.transform = 'translateX(0)';
                }
              }}
            >
              <Icon 
                style={{
                  ...styles.menuIcon,
                  ...(isActive ? styles.menuIconActive : {})
                }} 
              />
              {item.label}
            </button>
          );
        })}
      </nav>

      <div style={styles.footer}>
        <div style={styles.userInfo}>
          <div style={styles.avatar}>
            {(user?.displayName || user?.email || 'U')[0].toUpperCase()}
          </div>
          <div style={styles.userDetails}>
            <p style={styles.userName}>
              {user?.displayName || 'User'}
            </p>
            <p style={styles.userEmail}>
              {user?.email}
            </p>
          </div>
        </div>
        <button
          style={styles.logoutButton}
          onClick={onLogout}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.logoutButtonHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.backgroundColor = '#2563eb';
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.1)';
          }}
        >
          Sign Out
        </button>
      </div>
    </div>
  );
};

export default Sidebar;