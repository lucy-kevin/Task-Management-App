import React, { useState } from 'react';

const LoginForm = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [focusedField, setFocusedField] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      // Call the onLogin function passed as prop (which should handle Firebase auth)
      const result = await onLogin(email, password);
      
      if (!result.success) {
        setError(result.error || 'Login failed. Please try again.');
      }
      // If successful, the parent component will handle navigation to Dashboard
    } catch (error) {
      setError('An error occurred during login. Please try again.');
      console.error('Login error:', error);
    } finally {
      setLoading(false);
    }
  };

  const styles = {
    container: {
      minHeight: '100vh',
      backgroundColor: '#1e40af',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '1rem',
      position: 'relative',
      overflow: 'hidden'
    },
    backgroundElements: {
      position: 'absolute',
      inset: '0',
      overflow: 'hidden'
    },
    backgroundOrb1: {
      position: 'absolute',
      top: '-10rem',
      right: '-10rem',
      width: '20rem',
      height: '20rem',
      backgroundColor: '#60a5fa',
      borderRadius: '50%',
      mixBlendMode: 'multiply',
      filter: 'blur(64px)',
      opacity: '0.3',
      animation: 'pulse 2s infinite'
    },
    backgroundOrb2: {
      position: 'absolute',
      bottom: '-10rem',
      left: '-10rem',
      width: '20rem',
      height: '20rem',
      backgroundColor: 'white',
      borderRadius: '50%',
      mixBlendMode: 'multiply',
      filter: 'blur(64px)',
      opacity: '0.2',
      animation: 'pulse 2s infinite',
      animationDelay: '2s'
    },
    backgroundOrb3: {
      position: 'absolute',
      top: '10rem',
      left: '50%',
      width: '20rem',
      height: '20rem',
      backgroundColor: '#3b82f6',
      borderRadius: '50%',
      mixBlendMode: 'multiply',
      filter: 'blur(64px)',
      opacity: '0.3',
      animation: 'pulse 2s infinite',
      animationDelay: '4s'
    },
    loginCard: {
      position: 'relative',
      backdropFilter: 'blur(16px)',
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      border: '1px solid rgba(255, 255, 255, 0.2)',
      borderRadius: '1.5rem',
      boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)',
      padding: '2rem',
      width: '100%',
      maxWidth: '28rem',
      transform: 'scale(1)',
      transition: 'all 0.5s ease',
      cursor: 'default'
    },
    loginCardHover: {
      transform: 'scale(1.05)'
    },
    borderEffect: {
      position: 'absolute',
      inset: '0',
      borderRadius: '1.5rem',
      backgroundColor: 'white',
      padding: '2px'
    },
    borderInner: {
      backgroundColor: 'rgba(255, 255, 255, 0.1)',
      backdropFilter: 'blur(16px)',
      borderRadius: '1.5rem',
      height: '100%',
      width: '100%'
    },
    content: {
      position: 'relative',
      zIndex: '10'
    },
    header: {
      textAlign: 'center',
      marginBottom: '2rem'
    },
    iconContainer: {
      margin: '0 auto',
      width: '4rem',
      height: '4rem',
      backgroundColor: '#2563eb',
      borderRadius: '50%',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      marginBottom: '1rem',
      boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)'
    },
    title: {
      fontSize: '1.875rem',
      fontWeight: 'bold',
      color: '#1e40af',
      marginBottom: '0.5rem'
    },
    subtitle: {
      color: '#3b82f6'
    },
    errorContainer: {
      backgroundColor: 'rgba(239, 68, 68, 0.2)',
      border: '1px solid rgba(248, 113, 113, 0.3)',
      backdropFilter: 'blur(4px)',
      borderRadius: '0.75rem',
      padding: '1rem',
      marginBottom: '1.5rem',
      animation: 'shake 0.5s ease-in-out'
    },
    errorContent: {
      display: 'flex',
      alignItems: 'center'
    },
    errorText: {
      color: '#1e40af',
      fontSize: '0.875rem'
    },
    formContainer: {
      display: 'flex',
      flexDirection: 'column',
      gap: '1.5rem'
    },
    fieldContainer: {
      position: 'relative'
    },
    label: {
      display: 'block',
      color: '#1e40af',
      fontWeight: '500',
      marginBottom: '0.5rem',
      fontSize: '0.875rem'
    },
    inputContainer: {
      position: 'relative'
    },
    input: {
      width: '100%',
      padding: '1rem',
      backgroundColor: 'rgba(255, 255, 255, 0.9)',
      border: '1px solid rgba(30, 64, 175, 0.3)',
      borderRadius: '0.75rem',
      outline: 'none',
      transition: 'all 0.3s ease',
      color: '#1e40af',
      backdropFilter: 'blur(4px)'
    },
    inputFocused: {
      borderColor: '#60a5fa'
    },
    inputIcon: {
      position: 'absolute',
      right: '1rem',
      top: '50%',
      transform: 'translateY(-50%)',
      display: 'flex',
      alignItems: 'center',
      pointerEvents: 'none'
    },
    button: {
      width: '100%',
      backgroundColor: '#2563eb',
      color: 'white',
      padding: '1rem',
      borderRadius: '0.75rem',
      fontWeight: '600',
      fontSize: '1.125rem',
      border: 'none',
      cursor: 'pointer',
      transition: 'all 0.3s ease',
      transform: 'scale(1)',
      position: 'relative',
      overflow: 'hidden'
    },
    buttonHover: {
      backgroundColor: '#1d4ed8',
      transform: 'scale(1.05)',
      boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1)'
    },
    buttonDisabled: {
      opacity: '0.5',
      cursor: 'not-allowed'
    },
    loadingOverlay: {
      position: 'absolute',
      inset: '0',
      backgroundColor: '#1d4ed8',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    },
    spinner: {
      width: '1.5rem',
      height: '1.5rem',
      border: '2px solid white',
      borderTop: '2px solid transparent',
      borderRadius: '50%',
      animation: 'spin 1s linear infinite',
      marginRight: '0.5rem'
    },
    hoverEffect: {
      position: 'absolute',
      inset: '0',
      backgroundColor: 'white',
      color: '#2563eb',
      transform: 'scaleX(0)',
      transition: 'transform 0.3s ease',
      transformOrigin: 'left',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    },
    demoCredentials: {
      marginTop: '1.5rem',
      padding: '1rem',
      backgroundColor: 'rgba(255, 255, 255, 0.05)',
      borderRadius: '0.75rem',
      border: '1px solid rgba(255, 255, 255, 0.1)'
    },
    demoTitle: {
      color: '#3b82f6',
      fontSize: '0.875rem',
      textAlign: 'center',
      marginBottom: '0.5rem'
    },
    demoContent: {
      textAlign: 'center',
      display: 'flex',
      flexDirection: 'column',
      gap: '0.25rem'
    },
    demoText: {
      color: '#1e40af',
      fontSize: '0.875rem',
      fontFamily: 'monospace'
    },
    footer: {
      marginTop: '1.5rem',
      textAlign: 'center'
    },
    footerText: {
      color: '#3b82f6',
      fontSize: '0.875rem'
    },
    footerLink: {
      color: '#1e40af',
      marginLeft: '0.25rem',
      transition: 'color 0.3s ease',
      background: 'none',
      border: 'none',
      cursor: 'pointer',
      fontWeight: '600'
    }
  };

  return (
    <div>
      <div style={styles.container}>
        {/* Animated background elements */}
        <div style={styles.backgroundElements}>
          <div style={styles.backgroundOrb1}></div>
          <div style={styles.backgroundOrb2}></div>
          <div style={styles.backgroundOrb3}></div>
        </div>

        {/* Glassmorphism login card */}
        <div 
          style={styles.loginCard}
          onMouseEnter={(e) => {
            e.currentTarget.style.transform = 'scale(1.05)';
          }}
          onMouseLeave={(e) => {
            e.currentTarget.style.transform = 'scale(1)';
          }}
        >
          {/* Border effect */}
          <div style={styles.borderEffect}>
            <div style={styles.borderInner}></div>
          </div>
          
          {/* Content */}
          <div style={styles.content}>
            {/* Header with icon */}
            <div style={styles.header}>
              <div style={styles.iconContainer}>
                <svg style={{width: '2rem', height: '2rem', color: 'white'}} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h2 style={styles.title}>Welcome Back</h2>
              <p style={styles.subtitle}>Sign in to your admin account</p>
            </div>

            {/* Error message */}
            {error && (
              <div style={styles.errorContainer}>
                <div style={styles.errorContent}>
                  <svg style={{width: '1.25rem', height: '1.25rem', color: '#3b82f6', marginRight: '0.5rem'}} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <p style={styles.errorText}>{error}</p>
                </div>
              </div>
            )}

            {/* Form */}
            <div style={styles.formContainer}>
              {/* Email field */}
              <div style={styles.fieldContainer}>
                <label style={styles.label}>Email Address</label>
                <div style={styles.inputContainer}>
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    onFocus={() => setFocusedField('email')}
                    onBlur={() => setFocusedField('')}
                    style={{
                      ...styles.input,
                      ...(focusedField === 'email' ? styles.inputFocused : {})
                    }}
                    placeholder="admin@example.com"
                    required
                  />
                  <div style={styles.inputIcon}>
                    <svg style={{width: '1.25rem', height: '1.25rem', color: '#3b82f6'}} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207" />
                    </svg>
                  </div>
                </div>
              </div>

              {/* Password field */}
              <div style={styles.fieldContainer}>
                <label style={styles.label}>Password</label>
                <div style={styles.inputContainer}>
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    onFocus={() => setFocusedField('password')}
                    onBlur={() => setFocusedField('')}
                    style={{
                      ...styles.input,
                      ...(focusedField === 'password' ? styles.inputFocused : {})
                    }}
                    placeholder="••••••••"
                    required
                  />
                  <div style={styles.inputIcon}>
                    <svg style={{width: '1.25rem', height: '1.25rem', color: '#3b82f6'}} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                    </svg>
                  </div>
                </div>
              </div>

              {/* Submit button */}
              <button
                onClick={handleSubmit}
                disabled={loading}
                style={{
                  ...styles.button,
                  ...(loading ? styles.buttonDisabled : {})
                }}
                onMouseEnter={(e) => {
                  if (!loading) {
                    Object.assign(e.currentTarget.style, styles.buttonHover);
                    const hoverEffect = e.currentTarget.querySelector('.hover-effect');
                    if (hoverEffect) hoverEffect.style.transform = 'scaleX(1)';
                  }
                }}
                onMouseLeave={(e) => {
                  if (!loading) {
                    e.currentTarget.style.backgroundColor = '#2563eb';
                    e.currentTarget.style.transform = 'scale(1)';
                    e.currentTarget.style.boxShadow = 'none';
                    const hoverEffect = e.currentTarget.querySelector('.hover-effect');
                    if (hoverEffect) hoverEffect.style.transform = 'scaleX(0)';
                  }
                }}
              >
                {loading && (
                  <div style={styles.loadingOverlay}>
                    <div style={styles.spinner}></div>
                    <span>Signing in...</span>
                  </div>
                )}
                {!loading && (
                  <>
                    <span style={{position: 'relative', zIndex: '10'}}>Sign In</span>
                    <div 
                      className="hover-effect"
                      style={styles.hoverEffect}
                    >
                      <span style={{position: 'relative', zIndex: '10', color: '#2563eb'}}>Sign In</span>
                    </div>
                  </>
                )}
              </button>
            </div>

            {/* Demo credentials */}
            <div style={styles.demoCredentials}>
              <p style={styles.demoTitle}>Firebase Authentication</p>
              <div style={styles.demoContent}>
                <p style={styles.demoText}>Enter your registered email and password</p>
              </div>
            </div>

            {/* Footer links */}
            <div style={styles.footer}>
              <p style={styles.footerText}>
                Forgot your password? 
                <button 
                  style={styles.footerLink}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.color = '#2563eb';
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.color = '#1e40af';
                  }}
                >
                  Reset it here
                </button>
              </p>
            </div>
          </div>
        </div>
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 0.3; }
          50% { opacity: 0.6; }
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        @keyframes shake {
          0%, 100% { transform: translateX(0); }
          25% { transform: translateX(-5px); }
          75% { transform: translateX(5px); }
        }
        input::placeholder {
          color: rgba(30, 64, 175, 0.5);
        }
      `}</style>
    </div>
  );
};

export default LoginForm;