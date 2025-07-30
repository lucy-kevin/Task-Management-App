import React, { useState, useEffect } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';
import './App.css';
import Dashboard from './components/Dashboard'; 
import LoginForm from './components/LoginForm';
import Sidebar from './components/Sidebar';
import UserManagement from './components/UserManagement';
import TaskManagement from './components/TaskManagement';
import Analytics from './components/Analytics';

const firebaseConfig = {
  apiKey: "AIzaSyClausu1umd7XMICMom6cl--DvRr6DyMjE", 
  authDomain: "task-management-app-2e66e.firebaseapp.com",
  projectId: "task-management-app-2e66e",
  storageBucket: "task-management-app-2e66e.appspot.com",
  messagingSenderId: "89542425380",
  appId: "1:89542425380:android:ea7adc58171a8a744e51b1" 
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);

function App() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState('dashboard');

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      setLoading(false);
    });

    return () => unsubscribe();
  }, []);

  const handleLogin = async (email, password) => {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  const renderContent = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard />;
      case 'users':
        return <UserManagement />;
      case 'tasks':
        return <TaskManagement />;
      case 'analytics':
        return <Analytics />;
      default:
        return <Dashboard />;
    }
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner"></div>
        <p>Loading...</p>
      </div>
    );
  }

  if (!user) {
    return <LoginForm onLogin={handleLogin} />;
  }

  return (
    <div className="app">
      <Sidebar 
        currentPage={currentPage} 
        onPageChange={setCurrentPage}
        user={user}
        onLogout={handleLogout}
      />
      <main className="main-content">
        <header className="header">
          <h1>Task Manager Admin</h1>
          <div className="user-info">
            <span>Welcome, {user.displayName || user.email}</span>
          </div>
        </header>
        <div className="content">
          {renderContent()}
        </div>
      </main>
    </div>
  );
}

export default App;