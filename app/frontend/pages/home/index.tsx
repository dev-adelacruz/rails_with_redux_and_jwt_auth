import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { logoutUser } from '../../state/user/userSlice';
import { RootState } from '../../state/store';
import { HomeIcon, BarChartIcon, FileTextIcon, GearIcon, PersonIcon, ExitIcon } from '@radix-ui/react-icons';
import { Card, Button, Flex, Text, Avatar, DropdownMenu } from '@radix-ui/themes';
import './index.css';

const HomePage: React.FC = () => {
  const dispatch = useDispatch();
  const user = useSelector((state: RootState) => state.user.user);

  const handleLogout = () => {
    dispatch(logoutUser() as any);
  };

  return (
    <div className="dashboard">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <h2>Dashboard</h2>
        </div>
        <nav className="sidebar-nav">
          <ul>
            <li className="nav-item active">
              <HomeIcon className="nav-icon" />
              <span>Home</span>
            </li>
            <li className="nav-item">
              <BarChartIcon className="nav-icon" />
              <span>Analytics</span>
            </li>
            <li className="nav-item">
              <FileTextIcon className="nav-icon" />
              <span>Reports</span>
            </li>
            <li className="nav-item">
              <GearIcon className="nav-icon" />
              <span>Settings</span>
            </li>
          </ul>
        </nav>
        <div className="sidebar-footer">
          {/* Logout button removed as per request */}
        </div>
      </aside>

      {/* Main Content */}
      <main className="main-content">
        {/* Navbar */}
        <nav className="navbar">
          <Flex justify="between" align="center" style={{ width: '100%' }}>
            <div></div> {/* Spacer for alignment */}
            <DropdownMenu.Root>
              <DropdownMenu.Trigger>
                <Button variant="ghost" style={{ padding: 0, borderRadius: '50%' }}>
                  <Avatar
                    size="3"
                    radius="full"
                    fallback={user?.email?.charAt(0).toUpperCase() || 'U'}
                  />
                </Button>
              </DropdownMenu.Trigger>
              <DropdownMenu.Content align="end" sideOffset={5}>
                <DropdownMenu.Item>
                  <Flex align="center" gap="2">
                    <PersonIcon />
                    <Text size="2">Profile</Text>
                  </Flex>
                </DropdownMenu.Item>
                <DropdownMenu.Separator />
                <DropdownMenu.Item color="red" onClick={handleLogout}>
                  <Flex align="center" gap="2">
                    <ExitIcon />
                    <Text size="2">Logout</Text>
                  </Flex>
                </DropdownMenu.Item>
              </DropdownMenu.Content>
            </DropdownMenu.Root>
          </Flex>
        </nav>

        <header className="dashboard-header">
          <h1>Welcome, {user?.email || 'User'}!</h1>
          <p>Here's your dashboard overview</p>
        </header>

        {/* Statistics Grid */}
        <Flex gap="4" mb="4" wrap="wrap">
          <Card size="2" style={{ minWidth: '200px', flex: '1' }}>
            <Flex direction="column" align="center" gap="2">
              <Text size="8" weight="bold" color="blue">1,234</Text>
              <Text size="2" color="gray">Total Users</Text>
            </Flex>
          </Card>
          <Card size="2" style={{ minWidth: '200px', flex: '1' }}>
            <Flex direction="column" align="center" gap="2">
              <Text size="8" weight="bold" color="green">$45,678</Text>
              <Text size="2" color="gray">Revenue</Text>
            </Flex>
          </Card>
          <Card size="2" style={{ minWidth: '200px', flex: '1' }}>
            <Flex direction="column" align="center" gap="2">
              <Text size="8" weight="bold" color="orange">567</Text>
              <Text size="2" color="gray">Active Sessions</Text>
            </Flex>
          </Card>
        </Flex>

        {/* Cards Grid */}
        <Flex gap="4" wrap="wrap" mb="4">
          <Card size="3" style={{ minWidth: '300px', flex: '1' }}>
            <Flex direction="column" gap="3">
              <Text size="5" weight="bold">Recent Activity</Text>
              <Text size="2" color="gray">No recent activity</Text>
            </Flex>
          </Card>
          <Card size="3" style={{ minWidth: '300px', flex: '1' }}>
            <Flex direction="column" gap="3">
              <Text size="5" weight="bold">Notifications</Text>
              <Text size="2" color="gray">No new notifications</Text>
            </Flex>
          </Card>
          <Card size="3" style={{ minWidth: '300px', flex: '1' }}>
            <Flex direction="column" gap="3">
              <Text size="5" weight="bold">Quick Actions</Text>
              <Flex gap="2">
                <Button color="blue">Create New</Button>
                <Button variant="soft" color="gray">View Reports</Button>
              </Flex>
            </Flex>
          </Card>
        </Flex>

        {/* Data Table */}
        <Card size="3">
          <Flex direction="column" gap="3">
            <Text size="5" weight="bold">User Management</Text>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>John Doe</td>
                  <td>john@example.com</td>
                  <td>Admin</td>
                  <td>
                    <Text size="2" color="green">Active</Text>
                  </td>
                  <td>
                    <Flex gap="2">
                      <Button size="1" variant="ghost">Edit</Button>
                      <Button size="1" color="red" variant="ghost">Delete</Button>
                    </Flex>
                  </td>
                </tr>
                <tr>
                  <td>Jane Smith</td>
                  <td>jane@example.com</td>
                  <td>User</td>
                  <td>
                    <Text size="2" color="green">Active</Text>
                  </td>
                  <td>
                    <Flex gap="2">
                      <Button size="1" variant="ghost">Edit</Button>
                      <Button size="1" color="red" variant="ghost">Delete</Button>
                    </Flex>
                  </td>
                </tr>
                <tr>
                  <td>Bob Johnson</td>
                  <td>bob@example.com</td>
                  <td>Manager</td>
                  <td>
                    <Text size="2" color="orange">Pending</Text>
                  </td>
                  <td>
                    <Flex gap="2">
                      <Button size="1" variant="ghost">Edit</Button>
                      <Button size="1" color="red" variant="ghost">Delete</Button>
                    </Flex>
                  </td>
                </tr>
              </tbody>
            </table>
          </Flex>
        </Card>
      </main>
    </div>
  );
}

export default HomePage;
