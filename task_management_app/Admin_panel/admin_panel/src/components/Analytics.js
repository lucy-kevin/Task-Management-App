import React, { useEffect, useState } from "react";
import { BarChart3, TrendingUp, Users, CheckCircle, Clock, AlertTriangle } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Area, AreaChart } from 'recharts';
import { collection, getDocs, doc, deleteDoc, orderBy, query } from "firebase/firestore";
import { db } from "../App"; 

const Analytics = () => {
  const [analytics, setAnalytics] = useState({
    taskStats: {
      completed: 0,
      pending: 0,
      inProgress: 0,
      overdue: 0,
      total: 0
    },
    userStats: {
      totalUsers: 0,
      activeUsers: 0,
      newUsersThisMonth: 0
    },
    taskTrends: [],
    priorityDistribution: [],
    userActivity: []
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Helper function to get month name
  const getMonthName = (date) => {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.getMonth()];
  };

  // Helper function to get day name
  const getDayName = (dayIndex) => {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayIndex];
  };

  // Helper function to check if date is this month
  const isThisMonth = (date) => {
    const now = new Date();
    return date.getMonth() === now.getMonth() && date.getFullYear() === now.getFullYear();
  };

  // Helper function to check if user is active (has activity in last 30 days)
  const isActiveUser = (user) => {
    if (!user.lastActivity) return false;
    const lastActivity = user.lastActivity.toDate ? user.lastActivity.toDate() : new Date(user.lastActivity);
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    return lastActivity > thirtyDaysAgo;
  };

  // Fetch analytics data from Firebase
  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        setLoading(true);
        setError(null);
        
        // Fetch tasks and users from Firebase
        const [tasksSnapshot, usersSnapshot] = await Promise.all([
          getDocs(collection(db, "tasks")),
          getDocs(collection(db, "users"))
        ]);
        
        const tasks = [];
        const users = [];
        
        // Process tasks data
        tasksSnapshot.forEach((doc) => {
          const taskData = { id: doc.id, ...doc.data() };
          
          // Convert Firebase timestamps to dates if they exist
          if (taskData.createdAt) {
            taskData.createdAt = taskData.createdAt.toDate ? taskData.createdAt.toDate() : new Date(taskData.createdAt);
          }
          if (taskData.updatedAt) {
            taskData.updatedAt = taskData.updatedAt.toDate ? taskData.updatedAt.toDate() : new Date(taskData.updatedAt);
          }
          if (taskData.dueDate) {
            taskData.dueDate = taskData.dueDate.toDate ? taskData.dueDate.toDate() : new Date(taskData.dueDate);
          }
          
          tasks.push(taskData);
        });

        // Process users data
        usersSnapshot.forEach((doc) => {
          const userData = { id: doc.id, ...doc.data() };
          
          // Convert Firebase timestamps to dates if they exist
          if (userData.createdAt) {
            userData.createdAt = userData.createdAt.toDate ? userData.createdAt.toDate() : new Date(userData.createdAt);
          }
          if (userData.lastActivity) {
            userData.lastActivity = userData.lastActivity.toDate ? userData.lastActivity.toDate() : new Date(userData.lastActivity);
          }
          
          users.push(userData);
        });

        // Calculate task statistics
        const taskStats = {
          completed: tasks.filter(task => task.status === 'completed').length,
          pending: tasks.filter(task => task.status === 'pending').length,
          inProgress: tasks.filter(task => task.status === 'in-progress' || task.status === 'inProgress').length,
          overdue: tasks.filter(task => {
            if (!task.dueDate || task.status === 'completed') return false;
            return new Date(task.dueDate) < new Date();
          }).length,
          total: tasks.length
        };

        // Calculate user statistics
        const userStats = {
          totalUsers: users.length,
          activeUsers: users.filter(user => isActiveUser(user)).length,
          newUsersThisMonth: users.filter(user => user.createdAt && isThisMonth(user.createdAt)).length
        };

        // Calculate task trends (last 6 months)
        const taskTrends = [];
        const now = new Date();
        
        for (let i = 5; i >= 0; i--) {
          const monthDate = new Date(now.getFullYear(), now.getMonth() - i, 1);
          const nextMonthDate = new Date(now.getFullYear(), now.getMonth() - i + 1, 1);
          
          const monthTasks = tasks.filter(task => 
            task.createdAt && task.createdAt >= monthDate && task.createdAt < nextMonthDate
          );
          
          const completedInMonth = monthTasks.filter(task => 
            task.status === 'completed' && 
            task.updatedAt && 
            task.updatedAt >= monthDate && 
            task.updatedAt < nextMonthDate
          ).length;

          taskTrends.push({
            month: getMonthName(monthDate),
            completed: completedInMonth,
            created: monthTasks.length
          });
        }

        // Calculate priority distribution
        const priorityCounts = {
          high: tasks.filter(task => task.priority === 'high').length,
          medium: tasks.filter(task => task.priority === 'medium').length,
          low: tasks.filter(task => task.priority === 'low').length
        };

        const priorityDistribution = [
          { name: 'High', value: priorityCounts.high, color: '#ef4444' },
          { name: 'Medium', value: priorityCounts.medium, color: '#f59e0b' },
          { name: 'Low', value: priorityCounts.low, color: '#10b981' }
        ].filter(item => item.value > 0); // Only include priorities that have tasks

        // Calculate user activity (last 7 days)
        const userActivity = [];
        const today = new Date();
        
        for (let i = 6; i >= 0; i--) {
          const date = new Date(today);
          date.setDate(date.getDate() - i);
          const dayStart = new Date(date.setHours(0, 0, 0, 0));
          const dayEnd = new Date(date.setHours(23, 59, 59, 999));
          
          const activeOnDay = users.filter(user => 
            user.lastActivity && 
            user.lastActivity >= dayStart && 
            user.lastActivity <= dayEnd
          ).length;

          userActivity.push({
            day: getDayName(dayStart.getDay()),
            active: activeOnDay
          });
        }

        setAnalytics({
          taskStats,
          userStats,
          taskTrends,
          priorityDistribution,
          userActivity
        });
        
      } catch (err) {
        console.error("Error fetching analytics:", err);
        setError("Failed to load analytics data from Firebase. Please check your connection and try again.");
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
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
    grid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))',
      gap: '1.5rem',
      marginBottom: '2rem'
    },
    card: {
      backgroundColor: 'white',
      borderRadius: '1rem',
      boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      border: '1px solid #e2e8f0',
      overflow: 'hidden',
      transition: 'all 0.3s ease'
    },
    cardHover: {
      transform: 'translateY(-2px)',
      boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
    },
    cardHeader: {
      padding: '1.5rem',
      borderBottom: '1px solid #e2e8f0',
      backgroundColor: '#f8fafc'
    },
    cardTitle: {
      fontSize: '1.125rem',
      fontWeight: '600',
      color: '#1e293b',
      margin: '0',
      display: 'flex',
      alignItems: 'center',
      gap: '0.5rem'
    },
    cardContent: {
      padding: '1.5rem'
    },
    statCard: {
      backgroundColor: 'white',
      borderRadius: '1rem',
      boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
      border: '1px solid #e2e8f0',
      padding: '1.5rem',
      transition: 'all 0.3s ease',
      cursor: 'pointer'
    },
    statIcon: {
      width: '3rem',
      height: '3rem',
      borderRadius: '0.75rem',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      marginBottom: '1rem',
      color: 'white'
    },
    statValue: {
      fontSize: '2rem',
      fontWeight: 'bold',
      color: '#1e293b',
      margin: '0',
      lineHeight: '1'
    },
    statLabel: {
      fontSize: '0.875rem',
      color: '#64748b',
      margin: '0.25rem 0 0 0'
    },
    progressBar: {
      width: '100%',
      height: '0.5rem',
      backgroundColor: '#e2e8f0',
      borderRadius: '9999px',
      overflow: 'hidden',
      marginBottom: '0.5rem'
    },
    progressFill: {
      height: '100%',
      borderRadius: '9999px',
      transition: 'width 0.8s ease'
    },
    progressItem: {
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      marginBottom: '1rem'
    },
    progressLabel: {
      fontSize: '0.875rem',
      color: '#64748b',
      fontWeight: '500'
    },
    progressValue: {
      fontSize: '0.875rem',
      color: '#1e293b',
      fontWeight: '600'
    },
    chartContainer: {
      height: '300px',
      width: '100%'
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
    },
    errorMessage: {
      backgroundColor: '#fee2e2',
      color: '#dc2626',
      padding: '1rem',
      borderRadius: '0.5rem',
      marginBottom: '1rem',
      border: '1px solid #fca5a5'
    },
    largeGrid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))',
      gap: '1.5rem'
    },
    emptyState: {
      textAlign: 'center',
      padding: '2rem',
      color: '#64748b',
      backgroundColor: '#f8fafc',
      borderRadius: '0.5rem',
      border: '1px solid #e2e8f0'
    }
  };

  // Add CSS animation for loading spinner
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

  const getTaskCompletionRate = () => {
    const { completed, total } = analytics.taskStats;
    return total > 0 ? Math.round((completed / total) * 100) : 0;
  };

  const getStatusPercentage = (status) => {
    const { total } = analytics.taskStats;
    const count = analytics.taskStats[status];
    return total > 0 ? Math.round((count / total) * 100) : 0;
  };

  if (loading) {
    return (
      <div style={styles.container}>
        <div style={styles.loadingState}>
          <div style={styles.loadingSpinner}></div>
          <p style={styles.loadingText}>Loading analytics from Firebase...</p>
        </div>
      </div>
    );
  }

  // Show empty state if no data
  if (analytics.taskStats.total === 0 && analytics.userStats.totalUsers === 0) {
    return (
      <div style={styles.container}>
        <div style={styles.header}>
          <h2 style={styles.title}>Analytics Dashboard</h2>
          <p style={styles.subtitle}>Track your project performance and team productivity</p>
        </div>
        <div style={styles.emptyState}>
          <h3>No Data Available</h3>
          <p>Start adding tasks and users to see analytics data here.</p>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <div style={styles.header}>
        <h2 style={styles.title}>Analytics Dashboard</h2>
        <p style={styles.subtitle}>Track your project performance and team productivity</p>
      </div>

      {error && (
        <div style={styles.errorMessage}>
          {error}
        </div>
      )}

      {/* Key Metrics */}
      <div style={styles.grid}>
        <div 
          style={styles.statCard}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={{...styles.statIcon, backgroundColor: '#10b981'}}>
            <CheckCircle size={24} />
          </div>
          <div style={styles.statValue}>{analytics.taskStats.completed}</div>
          <div style={styles.statLabel}>Tasks Completed</div>
        </div>

        <div 
          style={styles.statCard}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={{...styles.statIcon, backgroundColor: '#3b82f6'}}>
            <Users size={24} />
          </div>
          <div style={styles.statValue}>{analytics.userStats.totalUsers}</div>
          <div style={styles.statLabel}>Total Users</div>
        </div>

        <div 
          style={styles.statCard}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={{...styles.statIcon, backgroundColor: '#f59e0b'}}>
            <TrendingUp size={24} />
          </div>
          <div style={styles.statValue}>{getTaskCompletionRate()}%</div>
          <div style={styles.statLabel}>Completion Rate</div>
        </div>

        <div 
          style={styles.statCard}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={{...styles.statIcon, backgroundColor: '#ef4444'}}>
            <AlertTriangle size={24} />
          </div>
          <div style={styles.statValue}>{analytics.userStats.activeUsers}</div>
          <div style={styles.statLabel}>Active Users</div>
        </div>
      </div>

      {/* Charts Section */}
      <div style={styles.largeGrid}>
        {/* Task Status Distribution */}
        <div 
          style={styles.card}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>
              <BarChart3 size={20} />
              Task Status Distribution
            </h3>
          </div>
          <div style={styles.cardContent}>
            <div style={{marginBottom: '1rem'}}>
              <div style={styles.progressItem}>
                <span style={styles.progressLabel}>Completed</span>
                <span style={styles.progressValue}>{getStatusPercentage('completed')}%</span>
              </div>
              <div style={styles.progressBar}>
                <div 
                  style={{
                    ...styles.progressFill,
                    width: `${getStatusPercentage('completed')}%`,
                    backgroundColor: '#10b981'
                  }}
                ></div>
              </div>
            </div>

            <div style={{marginBottom: '1rem'}}>
              <div style={styles.progressItem}>
                <span style={styles.progressLabel}>Pending</span>
                <span style={styles.progressValue}>{getStatusPercentage('pending')}%</span>
              </div>
              <div style={styles.progressBar}>
                <div 
                  style={{
                    ...styles.progressFill,
                    width: `${getStatusPercentage('pending')}%`,
                    backgroundColor: '#f59e0b'
                  }}
                ></div>
              </div>
            </div>

            <div style={{marginBottom: '1rem'}}>
              <div style={styles.progressItem}>
                <span style={styles.progressLabel}>In Progress</span>
                <span style={styles.progressValue}>{getStatusPercentage('inProgress')}%</span>
              </div>
              <div style={styles.progressBar}>
                <div 
                  style={{
                    ...styles.progressFill,
                    width: `${getStatusPercentage('inProgress')}%`,
                    backgroundColor: '#3b82f6'
                  }}
                ></div>
              </div>
            </div>

            <div>
              <div style={styles.progressItem}>
                <span style={styles.progressLabel}>Overdue</span>
                <span style={styles.progressValue}>{getStatusPercentage('overdue')}%</span>
              </div>
              <div style={styles.progressBar}>
                <div 
                  style={{
                    ...styles.progressFill,
                    width: `${getStatusPercentage('overdue')}%`,
                    backgroundColor: '#ef4444'
                  }}
                ></div>
              </div>
            </div>
          </div>
        </div>

        {/* Priority Distribution Pie Chart */}
        {analytics.priorityDistribution.length > 0 && (
          <div 
            style={styles.card}
            onMouseEnter={(e) => {
              Object.assign(e.currentTarget.style, styles.cardHover);
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'translateY(0)';
              e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
            }}
          >
            <div style={styles.cardHeader}>
              <h3 style={styles.cardTitle}>
                <Clock size={20} />
                Priority Distribution
              </h3>
            </div>
            <div style={styles.cardContent}>
              <div style={styles.chartContainer}>
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={analytics.priorityDistribution}
                      cx="50%"
                      cy="50%"
                      innerRadius={60}
                      outerRadius={100}
                      paddingAngle={5}
                      dataKey="value"
                    >
                      {analytics.priorityDistribution.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.color} />
                      ))}
                    </Pie>
                    <Tooltip />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>
        )}

        {/* Task Trends */}
        <div 
          style={styles.card}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>
              <TrendingUp size={20} />
              Task Trends (Last 6 Months)
            </h3>
          </div>
          <div style={styles.cardContent}>
            <div style={styles.chartContainer}>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={analytics.taskTrends}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="month" stroke="#64748b" />
                  <YAxis stroke="#64748b" />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '0.5rem',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                    }}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="completed" 
                    stackId="1"
                    stroke="#10b981" 
                    fill="#10b981"
                    fillOpacity={0.6}
                  />
                  <Area 
                    type="monotone" 
                    dataKey="created" 
                    stackId="2"
                    stroke="#3b82f6" 
                    fill="#3b82f6"
                    fillOpacity={0.6}
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* User Activity */}
        <div 
          style={styles.card}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, styles.cardHover);
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'translateY(0)';
            e.currentTarget.style.boxShadow = '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)';
          }}
        >
          <div style={styles.cardHeader}>
            <h3 style={styles.cardTitle}>
              <Users size={20} />
              Weekly User Activity
            </h3>
          </div>
          <div style={styles.cardContent}>
            <div style={styles.chartContainer}>
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={analytics.userActivity}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
                  <XAxis dataKey="day" stroke="#64748b" />
                  <YAxis stroke="#64748b" />
                  <Tooltip 
                    contentStyle={{
                      backgroundColor: 'white',
                      border: '1px solid #e2e8f0',
                      borderRadius: '0.5rem',
                      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                    }}
                  />
                  <Bar 
                    dataKey="active" 
                    fill="#3b82f6"
                    radius={[4, 4, 0, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;