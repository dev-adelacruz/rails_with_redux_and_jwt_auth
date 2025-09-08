import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../../state/user/userSlice';
import { RootState } from '../../state/store';
import {
  AppBar,
  Box,
  Button,
  Card,
  CardContent,
  Drawer,
  IconButton,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Toolbar,
  Typography,
  Paper
} from '@mui/material';
import { 
  ExitToApp, 
  Dashboard as DashboardIcon, 
  Notifications, 
  AccountCircle,
  Home,
  Settings,
  BarChart,
  People
} from '@mui/icons-material';

const HomePage: React.FC = () => {
  const dispatch = useDispatch();
  const user = useSelector((state: RootState) => state.user.user);

  const handleLogout = () => {
    dispatch(logoutUser() as any);
  };

  // Mock data for dashboard cards
  const dashboardData = [
    { title: 'Total Users', value: '1,234', icon: <AccountCircle /> },
    { title: 'Notifications', value: '42', icon: <Notifications /> },
    { title: 'Projects', value: '15', icon: <DashboardIcon /> },
    { title: 'Revenue', value: '$12,345', icon: <AccountCircle /> }
  ];

  // Sidebar navigation items
  const navItems = [
    { text: 'Dashboard', icon: <DashboardIcon /> },
    { text: 'Home', icon: <Home /> },
    { text: 'Users', icon: <People /> },
    { text: 'Reports', icon: <BarChart /> },
    { text: 'Settings', icon: <Settings /> }
  ];

  return (
    <Box sx={{ display: 'flex' }}>
      {/* Sidebar */}
      <Drawer
        variant="permanent"
        sx={{
          width: 240,
          flexShrink: 0,
          '& .MuiDrawer-paper': {
            width: 240,
            boxSizing: 'border-box',
          },
        }}
      >
        <Toolbar>
          <Typography variant="h6" noWrap component="div">
            Navigation
          </Typography>
        </Toolbar>
        <List>
          {navItems.map((item) => (
            <ListItemButton key={item.text}>
              <ListItemIcon>
                {item.icon}
              </ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          ))}
        </List>
      </Drawer>

      {/* Main Content */}
      <Box component="main" sx={{ flexGrow: 1, p: 3 }}>
        {/* App Bar */}
        <AppBar position="static" elevation={2} sx={{ mb: 4 }}>
          <Toolbar>
            <DashboardIcon sx={{ mr: 2 }} />
            <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
              Dashboard
            </Typography>
            <Typography variant="body1" sx={{ mr: 2 }}>
              Welcome, {user?.email || 'User'}!
            </Typography>
            <IconButton color="inherit" sx={{ mr: 1 }}>
              <Notifications />
            </IconButton>
            <Button 
              color="inherit" 
              onClick={handleLogout}
              startIcon={<ExitToApp />}
              sx={{ 
                backgroundColor: 'rgba(255,255,255,0.1)',
                '&:hover': { backgroundColor: 'rgba(255,255,255,0.2)' }
              }}
            >
              Logout
            </Button>
          </Toolbar>
        </AppBar>

        {/* Dashboard Cards */}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: 'repeat(2, 1fr)', md: 'repeat(4, 1fr)' }, gap: 3, mb: 4 }}>
          {dashboardData.map((item, index) => (
            <Card 
              key={index}
              elevation={3}
              sx={{ 
                height: '100%', 
                display: 'flex', 
                flexDirection: 'column',
                transition: 'transform 0.2s',
                '&:hover': {
                  transform: 'scale(1.02)',
                  boxShadow: 6
                }
              }}
            >
              <CardContent sx={{ flexGrow: 1, textAlign: 'center' }}>
                <Box sx={{ color: 'primary.main', mb: 1 }}>
                  {item.icon}
                </Box>
                <Typography variant="h5" component="h2" gutterBottom>
                  {item.value}
                </Typography>
                <Typography color="textSecondary">
                  {item.title}
                </Typography>
              </CardContent>
            </Card>
          ))}
        </Box>

        {/* Additional Content Section */}
        <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', md: '2fr 1fr' }, gap: 3 }}>
          <Paper elevation={3} sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Recent Activity
            </Typography>
            <Typography variant="body2" color="textSecondary">
              • User login detected - 2 hours ago
            </Typography>
            <Typography variant="body2" color="textSecondary">
              • Profile updated - 5 hours ago
            </Typography>
            <Typography variant="body2" color="textSecondary">
              • New project created - 1 day ago
            </Typography>
          </Paper>
          <Paper elevation={3} sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Quick Actions
            </Typography>
            <Button 
              variant="contained" 
              fullWidth 
              sx={{ mb: 1 }}
              disabled
            >
              Create Project
            </Button>
            <Button 
              variant="outlined" 
              fullWidth 
              sx={{ mb: 1 }}
              disabled
            >
              View Reports
            </Button>
            <Button 
              variant="outlined" 
              fullWidth
              disabled
            >
              Settings
            </Button>
          </Paper>
        </Box>
      </Box>
    </Box>
  );
}

export default HomePage;
