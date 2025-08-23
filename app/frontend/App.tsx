import { FC, useEffect } from 'react';
import { useDispatch } from 'react-redux';
import { checkAuthStatus } from './state/user/userSlice';
import AppRoutes from './routes';
import { Theme } from '@radix-ui/themes';

export const App: FC = () => {
  const dispatch = useDispatch();

  useEffect(() => {
    // Check authentication status when the app loads
    dispatch(checkAuthStatus() as any);
  }, [dispatch]);

  return (
    <Theme>
      <AppRoutes />
    </Theme>
  );
};
