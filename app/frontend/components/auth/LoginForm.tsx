import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../state/store';
import { loginUser, clearError } from '../../state/user/userSlice';
import { tokenStorage } from '../../services/tokenStorage';
import {
  Box,
  TextField,
  FormControlLabel,
  Checkbox,
  Button,
  Paper,
  Typography,
  Alert,
  CircularProgress
} from '@mui/material';
import { LockOutlined } from '@mui/icons-material';

interface LoginFormProps {
  onSuccess: () => void;
  onError: (error: string) => void;
}

const LoginForm: React.FC<LoginFormProps> = ({ onSuccess, onError }) => {
  const dispatch = useDispatch<AppDispatch>();
  const { isLoading, error } = useSelector((state: RootState) => state.user);
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);

  useEffect(() => {
    if (error) {
      onError(error);
      dispatch(clearError());
    }
  }, [error, onError, dispatch]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const result = await dispatch(loginUser({ email, password }));
    
    if (loginUser.fulfilled.match(result)) {
      // Store token based on remember me preference
      await tokenStorage.storeToken(result.payload.token, {
        encrypt: true,
        storageType: rememberMe ? 'local' : 'session'
      });
      onSuccess();
    }
  };

  return (
    <Paper elevation={3} sx={{ padding: 4, maxWidth: 400, margin: 'auto' }}>
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 3 }}>
        <LockOutlined sx={{ fontSize: 40, color: 'primary.main', mb: 1 }} />
        <Typography component="h1" variant="h5" sx={{ fontWeight: 'bold' }}>
          Sign In
        </Typography>
      </Box>

      <Box component="form" onSubmit={handleSubmit} sx={{ mt: 1 }}>
        <TextField
          margin="normal"
          required
          fullWidth
          id="email"
          label="Email Address"
          name="email"
          autoComplete="email"
          autoFocus
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          disabled={isLoading}
          variant="outlined"
          sx={{ mb: 2 }}
        />
        
        <TextField
          margin="normal"
          required
          fullWidth
          name="password"
          label="Password"
          type="password"
          id="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          disabled={isLoading}
          variant="outlined"
          sx={{ mb: 2 }}
        />
        
        <FormControlLabel
          control={
            <Checkbox
              checked={rememberMe}
              onChange={(e) => setRememberMe(e.target.checked)}
              color="primary"
              disabled={isLoading}
            />
          }
          label="Remember me"
          sx={{ mb: 2 }}
        />
        
        <Button
          type="submit"
          fullWidth
          variant="contained"
          disabled={isLoading}
          sx={{ 
            mt: 3, 
            mb: 2, 
            py: 1.5,
            fontSize: '1rem',
            fontWeight: 'bold'
          }}
          startIcon={isLoading ? <CircularProgress size={20} /> : null}
        >
          {isLoading ? 'Signing In...' : 'Sign In'}
        </Button>
      </Box>
    </Paper>
  );
};

export default LoginForm;
