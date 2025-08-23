import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { AppDispatch, RootState } from '../../state/store';
import { loginUser, clearError } from '../../state/user/userSlice';
import { tokenStorage } from '../../services/tokenStorage';
import * as Form from '@radix-ui/react-form';
import { Card, Button, Flex, Text, Checkbox, Heading } from '@radix-ui/themes';

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
    <Card size="4" style={{ maxWidth: '400px', width: '100%', padding: '2rem' }}>
      <Flex direction="column" gap="4">
        <Heading size="7" align="center" mb="4">
          Sign In
        </Heading>
        <Text size="2" color="gray" align="center" mb="3">
          Please enter your email and password
        </Text>

        <Form.Root onSubmit={handleSubmit}>
          <Flex direction="column" gap="4">
            <Form.Field name="email">
              <Flex direction="column" gap="2">
                <Form.Label>
                  <Text size="2" weight="medium">Email</Text>
                </Form.Label>
                <Form.Control asChild>
                  <input
                    type="email"
                    value={email}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
                    required
                    disabled={isLoading}
                    placeholder="Enter your email"
                    style={{
                      padding: 'var(--space-3) var(--space-4)',
                      border: '1px solid var(--gray-7)',
                      borderRadius: 'var(--radius-3)',
                      fontSize: 'var(--font-size-2)',
                      fontFamily: 'var(--font-family)',
                      backgroundColor: 'var(--color-background)',
                      color: 'var(--color-foreground)',
                      width: '100%'
                    }}
                  />
                </Form.Control>
                <Form.Message match="valueMissing">
                  <Text size="1" color="red">Please enter your email</Text>
                </Form.Message>
                <Form.Message match="typeMismatch">
                  <Text size="1" color="red">Please provide a valid email</Text>
                </Form.Message>
              </Flex>
            </Form.Field>

            <Form.Field name="password">
              <Flex direction="column" gap="2">
                <Form.Label>
                  <Text size="2" weight="medium">Password</Text>
                </Form.Label>
                <Form.Control asChild>
                  <input
                    type="password"
                    value={password}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
                    required
                    disabled={isLoading}
                    placeholder="Enter your password"
                    style={{
                      padding: 'var(--space-3) var(--space-4)',
                      border: '1px solid var(--gray-7)',
                      borderRadius: 'var(--radius-3)',
                      fontSize: 'var(--font-size-2)',
                      fontFamily: 'var(--font-family)',
                      backgroundColor: 'var(--color-background)',
                      color: 'var(--color-foreground)',
                      width: '100%'
                    }}
                  />
                </Form.Control>
                <Form.Message match="valueMissing">
                  <Text size="1" color="red">Please enter your password</Text>
                </Form.Message>
              </Flex>
            </Form.Field>

            <Flex justify="between" align="center">
              <Flex align="center" gap="2">
                <Checkbox
                  id="rememberMe"
                  checked={rememberMe}
                  onCheckedChange={(checked: boolean | 'indeterminate') => setRememberMe(checked === true)}
                  disabled={isLoading}
                />
                <Text as="label" htmlFor="rememberMe" size="2" style={{ cursor: 'pointer' }}>
                  Remember me
                </Text>
              </Flex>
              
              <Text size="2" color="blue" style={{ cursor: 'pointer' }}>
                Forgot password?
              </Text>
            </Flex>

            <Form.Submit asChild>
              <Button type="submit" disabled={isLoading} size="3" style={{ width: '100%' }}>
                {isLoading ? 'Logging in...' : 'Sign In'}
              </Button>
            </Form.Submit>
          </Flex>
        </Form.Root>

        <Text size="2" color="gray" align="center">
          Don't have an account?{' '}
          <Text color="blue" weight="medium" style={{ cursor: 'pointer' }}>
            Sign up
          </Text>
        </Text>
      </Flex>
    </Card>
  );
};

export default LoginForm;
