import React from 'react';
import { useNavigate } from 'react-router-dom';
import LoginForm from '../../components/auth/LoginForm';

const LoginPage: React.FC = () => {
  const navigate = useNavigate();

  const handleLoginSuccess = () => {
    // Redirect to home or dashboard after successful login
    navigate('/');
  };

  const handleLoginError = (error: string) => {
    // TODO: Display error message to user
    console.error('Login error:', error);
    alert(`Login failed: ${error}`);
  };

  return (
    <div className="login-page">
      <h1>Login</h1>
      <LoginForm 
        onSuccess={handleLoginSuccess}
        onError={handleLoginError}
      />
    </div>
  );
};

export default LoginPage;
