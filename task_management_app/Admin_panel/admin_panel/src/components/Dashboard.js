import React, { useState, useEffect } from 'react';
import { db } from '../App';
import { collection, getDocs, query, where, orderBy, limit } from 'firebase/firestore';
import { Line, Doughnut, Bar } from 'react-chartjs-2';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  BarElement,
} from 'chart.js';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  BarElement
);

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalTasks: 0,
    pendingTasks: 0,
    completedTasks: 0,
    overdueTasks: 0,
  });
  const [recentTasks, setRecentTasks] = useState([]);
  const [recentUsers, setRecentUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [taskTrends, setTaskTrends] = useState([]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // Fetch users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      const users = usersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Fetch tasks
      const tasksSnapshot = await getDocs(collection(db, 'tasks'));
      const tasks = tasksSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      // Calculate stats
      const now = new Date();
      const pendingTasks = tasks.filter(task => task.status === 'pending');
      const completedTasks = tasks.filter(task => task.status === 'completed');
      const overdueTasks = tasks.filter(task => 
        task.status === 'pending' && 
        task.dueDate && 
        task.dueDate.toDate() < now
      );

      setStats({
        totalUsers: users.length,
        totalTasks: tasks.length,
        pendingTasks: pendingTasks.length,
        completedTasks: completedTasks.length,
        overdueTasks: overdueTasks.length,
      });

      // Get recent tasks
      const recentTasksQuery = query(
        collection(db, 'tasks'),
        orderBy('createdAt', 'desc'),
        limit(5)
      );
      const recentTasksSnapshot = await getDocs(recentTasksQuery);
      const recentTasksData = recentTasksSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setRecentTasks(recentTasksData);

      // Get recent users
      const recentUsersQuery = query(
        collection(db, 'users'),
        orderBy('createdAt', 'desc'),
        limit(5)
      );
      const recentUsersSnapshot = await getDocs(recentUsersQuery);
      const recentUsersData = recentUsersSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setRecentUsers(recentUsersData);

      // Calculate task trends (last 7 days)
      const trends = calculateTaskTrends(tasks);
      setTaskTrends(trends);

    } catch (error) {
      console.error('Error fetching dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateTaskTrends = (tasks) => {
    const last7Days = [];
    const today = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      last7Days.push({
        date: date.toISOString().split('T')[0],
        created: 0,
        completed: 0,
      });
    }

    tasks.forEach(task => {
      if (task.createdAt) {
        const createdDate = task.createdAt.toDate().toISOString().split('T')[0];
        const dayIndex = last7Days.findIndex(day => day.date === createdDate);
        if (dayIndex !== -1) {
          last7Days[dayIndex].created++;
        }
      }

      if (task.status === 'completed' && task.updatedAt) {
        const completedDate = task.updatedAt.toDate().toISOString().split('T')[0];
        const dayIndex = last7Days.findIndex(day => day.date === completedDate);
        if (dayIndex !== -1) {
          last7Days[dayIndex].completed++;
        }
      }
    });

    return last7Days;
  };

  const taskStatusChartData = {
    labels: ['Pending', 'Completed', 'Overdue'],
    datasets: [
      {
        data: [stats.pendingTasks, stats.completedTasks, stats.overdueTasks],
        backgroundColor: ['#ff9800', '#4caf50', '#f44336'],
        borderWidth: 2,
        borderColor: '#fff',
      },
    ],
  };

  const taskTrendChartData = {
    labels: taskTrends.map(trend => 
      new Date(trend.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
    ),
    datasets: [
      {
        label: 'Tasks Created',
        data: taskTrends.map(trend => trend.created),
        borderColor: '#2196f3',
        backgroundColor: 'rgba(33, 150, 243, 0.1)',
        tension: 0.4,
      },
      {
        label: 'Tasks Completed',
        data: taskTrends.map(trend => trend.completed),
        borderColor: '#4caf50',
        backgroundColor: 'rgba(76, 175, 80, 0.1)',
        tension: 0.4,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top',
      },
    },
  };

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner"></div>
        <p>Loading dashboard...</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h2>Dashboard Overview</h2>
        <button onClick={fetchDashboardData} className="refresh-btn">
          Refresh Data
        </button>
      </div>

      {/* Stats Cards */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon users-icon">👥</div>
          <div className="stat-content">
            <h3>{stats.totalUsers}</h3>
            <p>Total Users</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon tasks-icon">📋</div>
          <div className="stat-content">
            <h3>{stats.totalTasks}</h3>
            <p>Total Tasks</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon pending-icon">⏳</div>
          <div className="stat-content">
            <h3>{stats.pendingTasks}</h3>
            <p>Pending Tasks</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon completed-icon">✅</div>
          <div className="stat-content">
            <h3>{stats.completedTasks}</h3>
            <p>Completed Tasks</p>
          </div>
        </div>
        
        <div className="stat-card">
          <div className="stat-icon overdue-icon">⚠️</div>
          <div className="stat-content">
            <h3>{stats.overdueTasks}</h3>
            <p>Overdue Tasks</p>
          </div>
        </div>
      </div>

      {/* Charts */}
      <div className="charts-grid">
        <div className="chart-card">
          <h3>Task Status Distribution</h3>
          <div className="chart-container">
            <Doughnut data={taskStatusChartData} options={chartOptions} />
          </div>
        </div>
        
        <div className="chart-card">
          <h3>Task Trends (Last 7 Days)</h3>
          <div className="chart-container">
            <Line data={taskTrendChartData} options={chartOptions} />
          </div>
        </div>
      </div>

      {/* Recent Activities */}
      <div className="recent-activities">
        <div className="recent-section">
          <h3>Recent Tasks</h3>
          <div className="recent-list">
            {recentTasks.length > 0 ? (
              recentTasks.map(task => (
                <div key={task.id} className="recent-item">
                  <div className="item-info">
                    <h4>{task.title}</h4>
                    <p className={`status ${task.status}`}>{task.status}</p>
                  </div>
                  <div className="item-date">
                    {task.createdAt && new Date(task.createdAt.toDate()).toLocaleDateString()}
                  </div>
                </div>
              ))
            ) : (
              <p className="no-data">No recent tasks</p>
            )}
          </div>
        </div>
        
        <div className="recent-section">
          <h3>Recent Users</h3>
          <div className="recent-list">
            {recentUsers.length > 0 ? (
              recentUsers.map(user => (
                <div key={user.id} className="recent-item">
                  <div className="item-info">
                    <h4>{user.displayName || user.email}</h4>
                    <p>{user.email}</p>
                  </div>
                  <div className="item-date">
                    {user.createdAt && new Date(user.createdAt.toDate()).toLocaleDateString()}
                  </div>
                </div>
              ))
            ) : (
              <p className="no-data">No recent users</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;