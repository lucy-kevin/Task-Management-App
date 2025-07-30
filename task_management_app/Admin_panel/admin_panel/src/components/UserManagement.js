import React, { useEffect, useState } from "react";
import { collection, getDocs } from "firebase/firestore";
import { db } from "../App"; 

const UserManagement = () => {
  const [users, setUsers] = useState([]);

  // Demo data for preview - replace with Firebase integration in your app
  useEffect(() => {
    // Simulate fetching users from Firebase
    const demoUsers = [
      {
        id: '1',
        displayName: 'John Doe',
        email: 'john.doe@example.com',
        role: 'admin',
        createdAt: new Date('2024-01-15')
      },
      {
        id: '2',
        displayName: 'Jane Smith',
        email: 'jane.smith@example.com',
        role: 'user',
        createdAt: new Date('2024-02-20')
      },
      {
        id: '3',
        displayName: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        role: 'user',
        createdAt: new Date('2024-03-10')
      },
      {
        id: '4',
        displayName: 'Sarah Wilson',
        email: 'sarah.wilson@example.com',
        role: 'user',
        createdAt: new Date('2024-03-25')
      }
    ];
    
    setUsers(demoUsers);
  }, []);

//   Firebase integration code (for your actual implementation):
  useEffect(() => {
    const fetchUsers = async () => {
      const usersCollection = collection(db, "users");
      const userSnapshot = await getDocs(usersCollection);
      const userList = userSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        createdAt: doc.data().createdAt?.toDate() || new Date(),
      }));
      setUsers(userList);
    };
    fetchUsers();
  }, []);

  const styles = {
    container: {
      padding: '2rem',
      backgroundColor: '#f8fafc',
      minHeight: '100vh',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    },
    header: {
      marginBottom: '2rem'
    },
    title: {
      fontSize: '2rem',
      fontWeight: 'bold',
      color: '#1e40af',
      margin: '0',
      marginBottom: '0.5rem'
    },
    subtitle: {
      color: '#64748b',
      fontSize: '1rem',
      margin: '0'
    },
    tableContainer: {
      backgroundColor: 'white',
      borderRadius: '1rem',
      boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      overflow: 'hidden',
      border: '1px solid #e2e8f0'
    },
    table: {
      width: '100%',
      borderCollapse: 'collapse'
    },
    tableHeader: {
      backgroundColor: '#1e40af',
      color: 'white'
    },
    tableHeaderCell: {
      padding: '1rem 1.5rem',
      textAlign: 'left',
      fontWeight: '600',
      fontSize: '0.875rem',
      textTransform: 'uppercase',
      letterSpacing: '0.05em',
      borderBottom: '1px solid #2563eb'
    },
    tableRow: {
      borderBottom: '1px solid #e2e8f0',
      transition: 'all 0.2s ease',
      cursor: 'pointer'
    },
    tableRowHover: {
      backgroundColor: '#f1f5f9',
      transform: 'translateY(-1px)',
      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
    },
    tableCell: {
      padding: '1rem 1.5rem',
      verticalAlign: 'middle'
    },
    userInfo: {
      display: 'flex',
      alignItems: 'center'
    },
    avatar: {
      width: '2.5rem',
      height: '2.5rem',
      backgroundColor: '#3b82f6',
      color: 'white',
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontWeight: 'bold',
      marginRight: '1rem',
      fontSize: '1rem',
      border: '2px solid #dbeafe',
      boxShadow: '0 2px 4px rgba(59, 130, 246, 0.2)'
    },
    userDetails: {
      display: 'flex',
      flexDirection: 'column'
    },
    userName: {
      fontWeight: '600',
      color: '#1e293b',
      fontSize: '0.875rem',
      margin: '0 0 0.25rem 0'
    },
    userEmail: {
      fontSize: '0.75rem',
      color: '#64748b',
      margin: '0'
    },
    roleBadge: {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '0.25rem 0.75rem',
      borderRadius: '9999px',
      fontSize: '0.75rem',
      fontWeight: '600',
      textTransform: 'capitalize'
    },
    roleAdmin: {
      backgroundColor: '#dbeafe',
      color: '#1e40af',
      border: '1px solid #3b82f6'
    },
    roleUser: {
      backgroundColor: '#f1f5f9',
      color: '#475569',
      border: '1px solid #94a3b8'
    },
    dateText: {
      color: '#64748b',
      fontSize: '0.875rem'
    },
    actions: {
      display: 'flex',
      gap: '0.5rem'
    },
    button: {
      padding: '0.5rem 1rem',
      borderRadius: '0.5rem',
      fontSize: '0.75rem',
      fontWeight: '600',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.2s ease',
      textTransform: 'uppercase',
      letterSpacing: '0.05em'
    },
    editButton: {
      backgroundColor: '#3b82f6',
      color: 'white',
      boxShadow: '0 2px 4px rgba(59, 130, 246, 0.2)'
    },
    editButtonHover: {
      backgroundColor: '#2563eb',
      transform: 'translateY(-1px)',
      boxShadow: '0 4px 6px rgba(59, 130, 246, 0.3)'
    },
    deleteButton: {
      backgroundColor: '#ef4444',
      color: 'white',
      boxShadow: '0 2px 4px rgba(239, 68, 68, 0.2)'
    },
    deleteButtonHover: {
      backgroundColor: '#dc2626',
      transform: 'translateY(-1px)',
      boxShadow: '0 4px 6px rgba(239, 68, 68, 0.3)'
    },
    emptyState: {
      textAlign: 'center',
      padding: '3rem',
      color: '#64748b'
    },
    emptyStateIcon: {
      fontSize: '3rem',
      marginBottom: '1rem'
    },
    emptyStateText: {
      fontSize: '1.125rem',
      fontWeight: '500',
      margin: '0'
    }
  };

  const handleEdit = (userId) => {
    console.log('Edit user:', userId);
    // Implement edit functionality
  };

  const handleDelete = (userId) => {
    console.log('Delete user:', userId);
    // Implement delete functionality
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2 style={styles.title}>User Management</h2>
        <p style={styles.subtitle}>Manage system users and their permissions</p>
      </div>
      
      <div style={styles.tableContainer}>
        <table style={styles.table}>
          <thead style={styles.tableHeader}>
            <tr>
              <th style={styles.tableHeaderCell}>User</th>
              <th style={styles.tableHeaderCell}>Role</th>
              <th style={styles.tableHeaderCell}>Created</th>
              <th style={styles.tableHeaderCell}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {users.length > 0 ? (
              users.map(user => (
                <tr 
                  key={user.id} 
                  style={styles.tableRow}
                  onMouseEnter={(e) => {
                    Object.assign(e.currentTarget.style, styles.tableRowHover);
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.backgroundColor = 'transparent';
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = 'none';
                  }}
                >
                  <td style={styles.tableCell}>
                    <div style={styles.userInfo}>
                      <div style={styles.avatar}>
                        {user.displayName?.[0]?.toUpperCase() || user.email?.[0]?.toUpperCase() || "U"}
                      </div>
                      <div style={styles.userDetails}>
                        <div style={styles.userName}>
                          {user.displayName || 'No Name'}
                        </div>
                        <div style={styles.userEmail}>
                          {user.email}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td style={styles.tableCell}>
                    <span 
                      style={{
                        ...styles.roleBadge,
                        ...(user.role === 'admin' ? styles.roleAdmin : styles.roleUser)
                      }}
                    >
                      {user.role || 'user'}
                    </span>
                  </td>
                  <td style={styles.tableCell}>
                    <span style={styles.dateText}>
                      {user.createdAt?.toLocaleDateString() || 'Unknown'}
                    </span>
                  </td>
                  <td style={styles.tableCell}>
                    <div style={styles.actions}>
                      <button
                        style={{...styles.button, ...styles.editButton}}
                        onClick={() => handleEdit(user.id)}
                        onMouseEnter={(e) => {
                          Object.assign(e.currentTarget.style, styles.editButtonHover);
                        }}
                        onMouseLeave={(e) => {
                          Object.assign(e.currentTarget.style, styles.editButton);
                          e.currentTarget.style.transform = 'translateY(0)';
                        }}
                      >
                        Edit
                      </button>
                      <button
                        style={{...styles.button, ...styles.deleteButton}}
                        onClick={() => handleDelete(user.id)}
                        onMouseEnter={(e) => {
                          Object.assign(e.currentTarget.style, styles.deleteButtonHover);
                        }}
                        onMouseLeave={(e) => {
                          Object.assign(e.currentTarget.style, styles.deleteButton);
                          e.currentTarget.style.transform = 'translateY(0)';
                        }}
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="4" style={styles.tableCell}>
                  <div style={styles.emptyState}>
                    <div style={styles.emptyStateIcon}>👥</div>
                    <p style={styles.emptyStateText}>No users found</p>
                  </div>
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default UserManagement;