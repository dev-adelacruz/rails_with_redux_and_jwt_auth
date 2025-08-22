import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../../state/user/userSlice';
import { RootState } from '../../state/store';

const HomePage: React.FC = () => {
  const dispatch = useDispatch();
  const user = useSelector((state: RootState) => state.user.user);

  const handleLogout = () => {
    dispatch(logoutUser() as any);
  };

  return (
    <div>
      <h1>This is the home page</h1>
      {user && user.email && (
        <p>Welcome, {user.email}!</p>
      )}
      <button 
        onClick={handleLogout}
        style={{
          padding: '10px 20px',
          backgroundColor: '#f44336',
          color: 'white',
          border: 'none',
          borderRadius: '4px',
          cursor: 'pointer',
          marginTop: '20px'
        }}
      >
        Logout
      </button>
    </div>
  );
}

export default HomePage;
