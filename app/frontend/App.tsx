import { FC, StrictMode } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { RootState } from './state/store';
import { signIn, signOut } from './state/user/userSlice';

export const App: FC = () => {
  const userSignedIn = useSelector((state: RootState) => state.user.isSignedIn);
  const dispatch = useDispatch();
  return (
    <StrictMode>
      <h1>Rails Template</h1>
      <h2>Logged {userSignedIn ? 'In' : 'Out'}</h2>
      <button onClick={() => dispatch(signIn())}>Sign In</button>
      <button onClick={() => dispatch(signOut())}>Sign Out</button>
    </StrictMode>
  )
};
  