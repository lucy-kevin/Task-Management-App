import React, { useEffect, useState } from "react";
import { collection, getDocs, doc, deleteDoc, orderBy, query } from "firebase/firestore";
import { db } from "../App"; 

const TaskManagement = () => {
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const style = document.createElement('style');
    style.textContent = `
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    `;
    document.head.appendChild(style);
    return () => document.head.removeChild(style);
  }, []);

  // Fetch tasks from Firebase
  useEffect(() => {
    const fetchTasks = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Create a query to order tasks by due date
        const tasksQuery = query(
          collection(db, "tasks"),
          orderBy("dueDate", "asc")
        );
        
        const taskSnapshot = await getDocs(tasksQuery);
        const taskList = taskSnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          // Convert Firestore timestamp to JavaScript Date
          dueDate: doc.data().dueDate?.toDate() || new Date(),
          createdAt: doc.data().createdAt?.toDate() || new Date(),
        }));
        
        setTasks(taskList);
      } catch (err) {
        console.error("Error fetching tasks:", err);
        setError("Failed to load tasks. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    fetchTasks();
  }, []);

  // Delete task from Firebase
  const handleDelete = async (taskId) => {
    if (window.confirm("Are you sure you want to delete this task?")) {
      try {
        await deleteDoc(doc(db, "tasks", taskId));
        // Remove task from local state
        setTasks(tasks.filter(task => task.id !== taskId));
      } catch (err) {
        console.error("Error deleting task:", err);
        alert("Failed to delete task. Please try again.");
      }
    }
  };

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
    taskInfo: {
      display: 'flex',
      alignItems: 'flex-start'
    },
    taskIcon: {
      width: '2.5rem',
      height: '2.5rem',
      backgroundColor: '#3b82f6',
      color: 'white',
      borderRadius: '0.75rem',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontWeight: 'bold',
      marginRight: '1rem',
      fontSize: '1rem',
      border: '2px solid #dbeafe',
      boxShadow: '0 2px 4px rgba(59, 130, 246, 0.2)',
      flexShrink: 0
    },
    taskDetails: {
      display: 'flex',
      flexDirection: 'column'
    },
    taskTitle: {
      fontWeight: '600',
      color: '#1e293b',
      fontSize: '0.875rem',
      margin: '0 0 0.25rem 0'
    },
    taskDescription: {
      fontSize: '0.75rem',
      color: '#64748b',
      margin: '0',
      lineHeight: '1.4'
    },
    priorityBadge: {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '0.25rem 0.75rem',
      borderRadius: '9999px',
      fontSize: '0.75rem',
      fontWeight: '600',
      textTransform: 'capitalize'
    },
    priorityHigh: {
      backgroundColor: '#fee2e2',
      color: '#dc2626',
      border: '1px solid #f87171'
    },
    priorityMedium: {
      backgroundColor: '#fef3c7',
      color: '#d97706',
      border: '1px solid #fbbf24'
    },
    priorityLow: {
      backgroundColor: '#dcfce7',
      color: '#16a34a',
      border: '1px solid #4ade80'
    },
    statusBadge: {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '0.25rem 0.75rem',
      borderRadius: '9999px',
      fontSize: '0.75rem',
      fontWeight: '600',
      textTransform: 'capitalize'
    },
    statusCompleted: {
      backgroundColor: '#dcfce7',
      color: '#16a34a',
      border: '1px solid #4ade80'
    },
    statusPending: {
      backgroundColor: '#fef3c7',
      color: '#d97706',
      border: '1px solid #fbbf24'
    },
    statusInProgress: {
      backgroundColor: '#dbeafe',
      color: '#2563eb',
      border: '1px solid #60a5fa'
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
    },
    errorMessage: {
      backgroundColor: '#fee2e2',
      color: '#dc2626',
      padding: '1rem',
      borderRadius: '0.5rem',
      marginBottom: '1rem',
      border: '1px solid #fca5a5'
    },
    loadingState: {
      textAlign: 'center',
      padding: '3rem',
      color: '#64748b'
    },
    loadingSpinner: {
      width: '2rem',
      height: '2rem',
      border: '3px solid #e2e8f0',
      borderTop: '3px solid #3b82f6',
      borderRadius: '50%',
      animation: 'spin 1s linear infinite',
      margin: '0 auto 1rem'
    },
    loadingText: {
      fontSize: '1rem',
      fontWeight: '500',
      margin: '0'
    }
  };

  const getTaskIcon = (title) => {
    const firstLetter = title?.[0]?.toUpperCase() || "T";
    return firstLetter;
  };

  const getPriorityStyle = (priority) => {
    switch (priority?.toLowerCase()) {
      case 'high':
        return styles.priorityHigh;
      case 'medium':
        return styles.priorityMedium;
      case 'low':
        return styles.priorityLow;
      default:
        return styles.priorityMedium;
    }
  };

  const getStatusStyle = (status) => {
    switch (status?.toLowerCase()) {
      case 'completed':
        return styles.statusCompleted;
      case 'pending':
        return styles.statusPending;
      case 'in-progress':
        return styles.statusInProgress;
      default:
        return styles.statusPending;
    }
  };

  const handleEdit = (taskId) => {
    console.log('Edit task:', taskId);
    // Implement edit functionality - you might want to open a modal or navigate to edit page
  };

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2 style={styles.title}>Task Management</h2>
        <p style={styles.subtitle}>Organize and track your project tasks</p>
      </div>
      
      {error && (
        <div style={styles.errorMessage}>
          {error}
        </div>
      )}
      
      <div style={styles.tableContainer}>
        {loading ? (
          <div style={styles.loadingState}>
            <div style={styles.loadingSpinner}></div>
            <p style={styles.loadingText}>Loading tasks...</p>
          </div>
        ) : (
          <table style={styles.table}>
            <thead style={styles.tableHeader}>
              <tr>
                <th style={styles.tableHeaderCell}>Task</th>
                <th style={styles.tableHeaderCell}>Priority</th>
                <th style={styles.tableHeaderCell}>Status</th>
                <th style={styles.tableHeaderCell}>Due Date</th>
                <th style={styles.tableHeaderCell}>Actions</th>
              </tr>
            </thead>
            <tbody>
            {tasks.length > 0 ? (
              tasks.map(task => (
                <tr 
                  key={task.id} 
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
                    <div style={styles.taskInfo}>
                      <div style={styles.taskIcon}>
                        {getTaskIcon(task.title)}
                      </div>
                      <div style={styles.taskDetails}>
                        <div style={styles.taskTitle}>
                          {task.title || 'Untitled Task'}
                        </div>
                        <div style={styles.taskDescription}>
                          {task.description || 'No description available'}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td style={styles.tableCell}>
                    <span 
                      style={{
                        ...styles.priorityBadge,
                        ...getPriorityStyle(task.priority)
                      }}
                    >
                      {task.priority || 'medium'}
                    </span>
                  </td>
                  <td style={styles.tableCell}>
                    <span 
                      style={{
                        ...styles.statusBadge,
                        ...getStatusStyle(task.status)
                      }}
                    >
                      {task.status || 'pending'}
                    </span>
                  </td>
                  <td style={styles.tableCell}>
                    <span style={styles.dateText}>
                      {task.dueDate?.toLocaleDateString() || 'No due date'}
                    </span>
                  </td>
                  <td style={styles.tableCell}>
                    <div style={styles.actions}>
                      <button
                        style={{...styles.button, ...styles.editButton}}
                        onClick={() => handleEdit(task.id)}
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
                        onClick={() => handleDelete(task.id)}
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
                <td colSpan="5" style={styles.tableCell}>
                  <div style={styles.emptyState}>
                    <div style={styles.emptyStateIcon}>📋</div>
                    <p style={styles.emptyStateText}>No tasks found</p>
                  </div>
                </td>
              </tr>
            )}
                      </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default TaskManagement;