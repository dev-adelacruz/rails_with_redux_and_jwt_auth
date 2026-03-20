# frozen_string_literal: true
# ============================================================
# Rails Template: Rails 7 + React + Redux + JWT Auth
# Usage:
#   rails new myapp -d postgresql -m path/to/template.rb
#   rails new myapp -d postgresql -m https://raw.githubusercontent.com/YOUR_USERNAME/rails_with_redux_and_jwt_auth/main/template.rb
# ============================================================

def source_paths
  [__dir__]
end

# ── Gems ─────────────────────────────────────────────────────
say "== Adding gems ==", :green

gem "blueprinter"
gem "devise"
gem "devise-jwt"
gem "rack-cors"
gem "vite_rails"
gem "rename"
gem "rswag-api"
gem "rswag-ui"

gem_group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry", "~> 0.15.0"
  gem "rspec-rails", "~> 6.1.0"
  gem "rswag-specs"
  gem "rubocop-ordered_methods", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-thread_safety", require: false
  gem "shoulda-matchers", "~> 6.0"
end

gem_group :development do
  gem "web-console"
end

# ── Bundle install ────────────────────────────────────────────
say "== Installing gems ==", :green
run "bundle install"

# ── Vite Rails setup ─────────────────────────────────────────
say "== Setting up Vite Rails ==", :green
run "bundle exec vite install"

# ── JS dependencies ───────────────────────────────────────────
say "== Adding JS dependencies ==", :green
run "yarn add react react-dom react-router-dom react-redux @reduxjs/toolkit lucide-react tailwindcss @tailwindcss/vite"
run "yarn add --dev @vitejs/plugin-react @types/react @types/react-dom @types/styled-components typescript vite vite-plugin-ruby vite-tsconfig-paths"

# ── vite.config.ts ───────────────────────────────────────────
say "== Writing vite.config.ts ==", :green
create_file "vite.config.ts", force: true do
  <<~TS
    import { defineConfig } from 'vite'
    import RubyPlugin from 'vite-plugin-ruby'
    import tailwindcss from "@tailwindcss/vite";

    export default defineConfig({
      plugins: [
        RubyPlugin(),
        tailwindcss(),
      ]
    })
  TS
end

# ── tsconfig.json ────────────────────────────────────────────
say "== Writing tsconfig.json ==", :green
create_file "tsconfig.json", force: true do
  <<~JSON
    {
      "compilerOptions": {
        "target": "ESNext",
        "useDefineForClassFields": true,
        "lib": ["DOM", "DOM.Iterable", "ESNext"],
        "allowJs": false,
        "esModuleInterop": false,
        "allowSyntheticDefaultImports": true,
        "strict": true,
        "forceConsistentCasingInFileNames": true,
        "module": "ESNext",
        "moduleResolution": "Node",
        "resolveJsonModule": true,
        "isolatedModules": true,
        "noEmit": true,
        "jsx": "react-jsx",
        "baseUrl": "./",
        "paths": {
          "@/*": ["app/frontend/*"],
          "@api/*": ["app/frontend/api/services/*"]
        },
        "types": ["vite/client"],
        "skipLibCheck": true
      },
      "include": ["app/frontend/**/*"]
    }
  JSON
end

# ── tailwind.config.js ───────────────────────────────────────
say "== Writing tailwind.config.js ==", :green
create_file "tailwind.config.js", force: true do
  <<~JS
    // tailwind.config.js

    module.exports = {
      content: [
        "./app/frontend/**/*.{html,js,jsx,ts,tsx}", // Update according to your project file structure
      ],
      theme: {
        extend: {},
      },
      plugins: [],
    }
  JS
end

# ── Procfile.dev ─────────────────────────────────────────────
create_file "Procfile.dev", force: true do
  <<~PROC

    vite: bin/vite dev
    web: bin/rails s -p 3000
  PROC
end

# ── Application layout ───────────────────────────────────────
say "== Updating application layout ==", :green
remove_file "app/views/layouts/application.html.erb"
create_file "app/views/layouts/application.html.erb" do
  <<~ERB
    <!DOCTYPE html>
    <html>
      <head>
        <title>RailsTemplate</title>
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <%= csrf_meta_tags %>
        <%= csp_meta_tag %>
        <%= vite_client_tag %>
        <%= vite_stylesheet_tag 'tailwind.css' %>
      </head>

      <body class="bg-gradient-to-br from-slate-100 via-blue-50 to-indigo-100 min-h-screen flex items-center justify-center p-4">
        <%= yield %>
        <div id="root"></div>
        <%= vite_javascript_tag 'application.tsx' %>
      </body>
    </html>
  ERB
end

# ── Frontend directory structure ─────────────────────────────
say "== Creating frontend structure ==", :green

# Tailwind CSS
create_file "app/frontend/assets/styles/tailwind.css" do
  <<~CSS
    @import 'tailwindcss';

    @layer base {
      html, body, #root {
        @apply h-full;
      }
    }
  CSS
end

# Entrypoint
create_file "app/frontend/entrypoints/application.tsx" do
  <<~TSX
    import { createRoot } from 'react-dom/client';
    import { App } from '../App';
    import { Provider } from 'react-redux';
    import { store } from '../state/store';

    const container = document.getElementById('root');

    if(container) {
      const root = createRoot(container);
      root.render(
        <Provider store={store}>
          <App />
        </Provider>
      )
    }
  TSX
end

# App.tsx
create_file "app/frontend/App.tsx" do
  <<~TSX
    import { FC, useEffect } from 'react';
    import { useDispatch } from 'react-redux';
    import { checkAuthStatus } from './state/user/userSlice';
    import AppRoutes from './routes';
    import './assets/styles/tailwind.css';

    export const App: FC = () => {
      const dispatch = useDispatch();

      useEffect(() => {
        // Check authentication status when the app loads
        dispatch(checkAuthStatus() as any);
      }, [dispatch]);

      return (
        <div className="h-screen w-screen">
          <AppRoutes />
        </div>
      );
    };
  TSX
end

# Routes
create_file "app/frontend/routes/index.tsx" do
  <<~TSX
    import React from 'react';
    import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
    import HomePage from '../pages/home';
    import LoginPage from '../pages/login';
    import ProtectedRoute from '../components/ProtectedRoute';

    const AppRoutes: React.FC = () => {
      return (
        <Router>
          <Routes>
            <Route path='/' element={
              <ProtectedRoute>
                <HomePage/>
              </ProtectedRoute>
            } />
            <Route path='/login' element={<LoginPage/>} />
          </Routes>
        </Router>
      )
    }

    export default AppRoutes;
  TSX
end

# Redux store
create_file "app/frontend/state/store.tsx" do
  <<~TSX
    import { configureStore } from '@reduxjs/toolkit';
    import userReducer from './user/userSlice';

    export const store = configureStore({
      reducer: {
        user: userReducer,
      }
    })

    export type RootState = ReturnType<typeof store.getState>;
    export type AppDispatch = typeof store.dispatch;
  TSX
end

# UserState interface
create_file "app/frontend/interfaces/state/userState.tsx" do
  <<~TSX
    interface UserState {
      isSignedIn: boolean;
      token: string | null;
      user: {
        id: number | null;
        email: string | null;
      } | null;
      isLoading: boolean;
      error: string | null;
    }
  TSX
end

# User slice
create_file "app/frontend/state/user/userSlice.tsx" do
  <<~TSX
    import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
    import { authService } from '../../services/authService';
    import { tokenStorage } from '../../services/tokenStorage';

    // Async thunks for authentication
    export const loginUser = createAsyncThunk(
      'user/login',
      async (credentials: { email: string; password: string }, { rejectWithValue }) => {
        try {
          const response = await authService.login(credentials);
          // Store token in localStorage without encryption for persistence
          await tokenStorage.storeToken(response.token, {
            encrypt: false,
            storageType: 'local'
          });
          return response;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Login failed');
        }
      }
    );

    export const logoutUser = createAsyncThunk(
      'user/logout',
      async (_, { rejectWithValue }) => {
        try {
          await authService.logout();
          // Clear token from storage on logout
          tokenStorage.clearToken();
          return null;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Logout failed');
        }
      }
    );

    export const checkAuthStatus = createAsyncThunk(
      'user/checkAuth',
      async (_, { rejectWithValue }) => {
        try {
          const token = await tokenStorage.getToken();
          
          if (token) {
            const isValid = await authService.validateToken(token);
            
            if (isValid) {
              // For now, return only the token; user data can be fetched separately if needed
              return { token, user: null };
            }
          }
          return null;
        } catch (error: any) {
          return rejectWithValue(error.message || 'Auth check failed');
        }
      }
    );

    const initialState: UserState = {
      isSignedIn: false,
      token: null,
      user: null,
      isLoading: false,
      error: null
    };

    const userSlice = createSlice({
      name: 'User',
      initialState,
      reducers: {
        signIn: (state) => {
          state.isSignedIn = true
        },
        signOut: (state) => {
          state.isSignedIn = false
          state.token = null
          state.user = null
        },
        clearError: (state) => {
          state.error = null
        }
      },
      extraReducers: (builder) => {
        // Login cases
        builder.addCase(loginUser.pending, (state) => {
          state.isLoading = true
          state.error = null
        })
        builder.addCase(loginUser.fulfilled, (state, action) => {
          state.isLoading = false
          state.isSignedIn = true
          state.token = action.payload.token
          state.user = action.payload.user
          state.error = null
        })
        builder.addCase(loginUser.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })

        // Logout cases
        builder.addCase(logoutUser.pending, (state) => {
          state.isLoading = true
        })
        builder.addCase(logoutUser.fulfilled, (state) => {
          state.isLoading = false
          state.isSignedIn = false
          state.token = null
          state.user = null
          state.error = null
        })
        builder.addCase(logoutUser.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })

        // Check auth status cases
        builder.addCase(checkAuthStatus.pending, (state) => {
          state.isLoading = true
        })
        builder.addCase(checkAuthStatus.fulfilled, (state, action) => {
          state.isLoading = false
          if (action.payload) {
            state.isSignedIn = true
            state.token = action.payload.token
            state.user = action.payload.user
          } else {
            state.isSignedIn = false
            state.token = null
            state.user = null
          }
          state.error = null
        })
        builder.addCase(checkAuthStatus.rejected, (state, action) => {
          state.isLoading = false
          state.error = action.payload as string
        })
      }
    })

    export const { signIn, signOut, clearError } = userSlice.actions;
    export default userSlice.reducer;
  TSX
end

# Auth service
create_file "app/frontend/services/authService.ts" do
  <<~TS
    // Authentication service for handling API calls
    export interface LoginCredentials {
      email: string;
      password: string;
    }

    export interface AuthResponse {
      token: string;
      user: {
        id: number;
        email: string;
        // Add other user fields as needed
      };
      expires_in?: number;
    }

    export interface ApiError {
      message: string;
      status?: number;
    }

    class AuthService {
      private baseURL = '/api/v1';

      async login(credentials: LoginCredentials): Promise<AuthResponse> {
        try {
          const response = await fetch(`${this.baseURL}/users/sign_in`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ user: credentials }),
          });

          if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `Login failed with status ${response.status}`);
          }

          const data: AuthResponse = await response.json();
          return data;
        } catch (error) {
          if (error instanceof Error) {
            throw new Error(error.message);
          }
          throw new Error('An unexpected error occurred during login');
        }
      }

      async logout(): Promise<void> {
        try {
          const response = await fetch(`${this.baseURL}/users/sign_out`, {
            method: 'DELETE',
            headers: {
              'Content-Type': 'application/json',
            },
          });

          if (!response.ok) {
            throw new Error(`Logout failed with status ${response.status}`);
          }
        } catch (error) {
          console.error('Logout error:', error);
          // Even if logout fails, we should clear local auth state
          throw error;
        }
      }

      async validateToken(token: string): Promise<boolean> {
        try {
          const response = await fetch(`${this.baseURL}/users/validate_token`, {
            method: 'GET',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json',
            },
          });

          console.log('Token validation response status:', response.status);
          if (!response.ok) {
            console.log('Token validation failed with status:', response.status);
            return false;
          }
          return true;
        } catch (error) {
          console.error('Token validation error:', error);
          return false;
        }
      }

      // Helper method to set authorization header for future requests
      setAuthHeader(token: string): void {
        // This can be used to configure fetch defaults if needed
        // For now, we'll handle headers in each request
      }
    }

    export const authService = new AuthService();
  TS
end

# Token storage
create_file "app/frontend/services/tokenStorage.ts" do
  <<~TS
    // Token storage service with encryption and security features

    export interface TokenStorageOptions {
      encrypt?: boolean;
      storageType: 'local' | 'session';
    }

    class TokenStorage {
      private readonly TOKEN_KEY = 'auth_token';
      private readonly STORAGE_TYPE_KEY = 'auth_storage_type';
      private encryptionKey: CryptoKey | null = null;

      // Initialize encryption if needed
      async initializeEncryption(): Promise<void> {
        if (typeof window !== 'undefined' && window.crypto) {
          try {
            this.encryptionKey = await crypto.subtle.generateKey(
              {
                name: 'AES-GCM',
                length: 256,
              },
              true,
              ['encrypt', 'decrypt']
            );
          } catch (error) {
            console.warn('Web Crypto API not available, falling back to plain text storage');
            this.encryptionKey = null;
          }
        }
      }

      // Encrypt token using Web Crypto API
      private async encryptToken(token: string): Promise<string> {
        if (!this.encryptionKey) {
          return token; // Fallback to plain text if encryption is not available
        }

        try {
          const encoder = new TextEncoder();
          const data = encoder.encode(token);
          const iv = crypto.getRandomValues(new Uint8Array(12));
          
          const encrypted = await crypto.subtle.encrypt(
            {
              name: 'AES-GCM',
              iv: iv,
            },
            this.encryptionKey,
            data
          );

          // Combine IV and encrypted data for storage
          const combined = new Uint8Array(iv.length + encrypted.byteLength);
          combined.set(iv, 0);
          combined.set(new Uint8Array(encrypted), iv.length);

          return btoa(String.fromCharCode(...combined));
        } catch (error) {
          console.error('Encryption failed:', error);
          return token; // Fallback to plain text
        }
      }

      // Decrypt token using Web Crypto API
      private async decryptToken(encryptedToken: string): Promise<string> {
        if (!this.encryptionKey) {
          return encryptedToken; // Return as is if encryption was not used
        }

        try {
          const combined = Uint8Array.from(atob(encryptedToken), c => c.charCodeAt(0));
          const iv = combined.slice(0, 12);
          const encryptedData = combined.slice(12);

          const decrypted = await crypto.subtle.decrypt(
            {
              name: 'AES-GCM',
              iv: iv,
            },
            this.encryptionKey,
            encryptedData
          );

          const decoder = new TextDecoder();
          return decoder.decode(decrypted);
        } catch (error) {
          console.error('Decryption failed:', error);
          return encryptedToken; // Return as is if decryption fails
        }
      }

      // Store token with specified storage type
      async storeToken(token: string, options: TokenStorageOptions): Promise<void> {
        await this.initializeEncryption();
        
        let tokenToStore = token;
        if (options.encrypt && this.encryptionKey) {
          tokenToStore = await this.encryptToken(token);
        }

        const storage = options.storageType === 'local' ? localStorage : sessionStorage;
        
        storage.setItem(this.TOKEN_KEY, tokenToStore);
        localStorage.setItem(this.STORAGE_TYPE_KEY, options.storageType);
      }

      // Retrieve token from storage
      async getToken(): Promise<string | null> {
        await this.initializeEncryption();
        
        // Check both storage locations
        let encryptedToken = localStorage.getItem(this.TOKEN_KEY) || sessionStorage.getItem(this.TOKEN_KEY);
        
        if (!encryptedToken) {
          return null;
        }

        // Get storage type to determine if encryption was used
        const storageType = localStorage.getItem(this.STORAGE_TYPE_KEY) as 'local' | 'session' | null;
        
        if (storageType && this.encryptionKey) {
          try {
            return await this.decryptToken(encryptedToken);
          } catch (error) {
            console.error('Failed to decrypt token:', error);
            return encryptedToken; // Return encrypted token as fallback
          }
        }

        return encryptedToken;
      }

      // Clear token from all storage locations
      clearToken(): void {
        localStorage.removeItem(this.TOKEN_KEY);
        sessionStorage.removeItem(this.TOKEN_KEY);
        localStorage.removeItem(this.STORAGE_TYPE_KEY);
      }

      // Get the storage type used for the current token
      getStorageType(): 'local' | 'session' | null {
        return localStorage.getItem(this.STORAGE_TYPE_KEY) as 'local' | 'session' | null;
      }

      // Check if a token exists
      hasToken(): boolean {
        return !!(localStorage.getItem(this.TOKEN_KEY) || sessionStorage.getItem(this.TOKEN_KEY));
      }
    }

    export const tokenStorage = new TokenStorage();
  TS
end

# ProtectedRoute
create_file "app/frontend/components/ProtectedRoute.tsx" do
  <<~TSX
    import React, { useEffect, useState } from 'react';
    import { Navigate } from 'react-router-dom';
    import { useSelector } from 'react-redux';
    import { RootState } from '../state/store';

    interface ProtectedRouteProps {
      children: React.ReactNode;
    }

    const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
      const isSignedIn = useSelector((state: RootState) => state.user.isSignedIn);
      const isLoading = useSelector((state: RootState) => state.user.isLoading);
      const [authChecked, setAuthChecked] = useState(false);

      useEffect(() => {
        // Mark that auth check has completed when loading finishes
        if (!isLoading) {
          setAuthChecked(true);
        }
      }, [isLoading]);

      // Show loading state while checking authentication
      if (isLoading) {
        return <div>Loading...</div>;
      }

      // Only redirect if auth check has completed and user is not signed in
      if (authChecked && !isSignedIn) {
        return <Navigate to="/login" replace />;
      }

      // Don't render anything until auth check is complete
      if (!authChecked) {
        return <div>Loading...</div>;
      }

      return <>{children}</>;
    };

    export default ProtectedRoute;
  TSX
end

# LoginForm
create_file "app/frontend/components/auth/LoginForm.tsx" do
  <<~TSX
    import React, { useState, useEffect } from 'react';
    import { useDispatch, useSelector } from 'react-redux';
    import { AppDispatch, RootState } from '../../state/store';
    import { loginUser, clearError } from '../../state/user/userSlice';
    import { tokenStorage } from '../../services/tokenStorage';
    import { Mail, Lock, LogIn, Zap } from 'lucide-react';

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
        <div className="w-full bg-white rounded-2xl shadow-2xl overflow-hidden border border-gray-100">
          {/* Accent bar */}
          <div className="h-1.5 w-full bg-gradient-to-r from-blue-500 via-indigo-500 to-purple-500" />

          <div className="p-10 space-y-8">
            {/* Branding */}
            <div className="text-center space-y-3">
              <div className="inline-flex items-center justify-center w-14 h-14 rounded-2xl bg-blue-600 shadow-lg shadow-blue-200 mb-1">
                <Zap className="w-7 h-7 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold text-gray-900">Welcome back</h1>
                <p className="mt-1 text-sm text-gray-500">Sign in to your account to continue</p>
              </div>
            </div>

            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="relative">
                <Mail className="absolute w-4.5 h-4.5 text-gray-400 top-3.5 left-3.5" />
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  disabled={isLoading}
                  placeholder="Email address"
                  className="w-full pl-10 pr-4 py-3 text-gray-800 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white focus:border-transparent transition-all duration-150 disabled:opacity-50"
                />
              </div>
              <div className="relative">
                <Lock className="absolute w-4.5 h-4.5 text-gray-400 top-3.5 left-3.5" />
                <input
                  type="password"
                  id="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  disabled={isLoading}
                  placeholder="Password"
                  className="w-full pl-10 pr-4 py-3 text-gray-800 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:bg-white focus:border-transparent transition-all duration-150 disabled:opacity-50"
                />
              </div>
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    type="checkbox"
                    id="rememberMe"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    disabled={isLoading}
                    className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded focus:ring-blue-500"
                  />
                  <label htmlFor="rememberMe" className="ml-2 text-sm text-gray-600">
                    Remember me
                  </label>
                </div>
                <a href="#" className="text-sm font-medium text-blue-600 hover:text-blue-700 transition-colors duration-150">
                  Forgot password?
                </a>
              </div>
              <button
                type="submit"
                disabled={isLoading}
                className="flex items-center justify-center w-full px-4 py-3 font-semibold text-white bg-blue-600 rounded-xl hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 transition-colors duration-150 shadow-md shadow-blue-200"
              >
                {isLoading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin w-4 h-4" viewBox="0 0 24 24" fill="none">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z" />
                    </svg>
                    Signing in…
                  </span>
                ) : (
                  <>
                    <LogIn className="w-4 h-4 mr-2" />
                    Sign in
                  </>
                )}
              </button>
            </form>
          </div>
        </div>
      );
    };

    export default LoginForm;
  TSX
end

# Login page
create_file "app/frontend/pages/login/index.tsx" do
  <<~TSX
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
        <div className="flex items-center justify-center min-h-screen">
          <div className="w-full max-w-md px-4">
            <LoginForm
              onSuccess={handleLoginSuccess}
              onError={handleLoginError}
            />
          </div>
        </div>
      );
    };

    export default LoginPage;
  TSX
end

# Home page
create_file "app/frontend/pages/home/index.tsx" do
  <<~TSX
    import React, { useRef, useState, useEffect } from 'react';
    import { useDispatch, useSelector } from 'react-redux';
    import { logoutUser } from '../../state/user/userSlice';
    import { RootState } from '../../state/store';
    import {
      LayoutDashboard, User, Settings, LogOut, Bell,
      ChevronDown, Zap, TrendingUp, Users, ShoppingCart,
      DollarSign, ArrowUpRight, ArrowDownRight,
    } from 'lucide-react';

    const statCards = [
      {
        label: 'Total Revenue',
        value: '$48,295',
        change: '+12.5%',
        up: true,
        icon: DollarSign,
        iconBg: 'bg-blue-100',
        iconColor: 'text-blue-600',
        accent: 'from-blue-500 to-blue-600',
      },
      {
        label: 'Active Users',
        value: '3,842',
        change: '+8.1%',
        up: true,
        icon: Users,
        iconBg: 'bg-indigo-100',
        iconColor: 'text-indigo-600',
        accent: 'from-indigo-500 to-indigo-600',
      },
      {
        label: 'New Orders',
        value: '1,209',
        change: '-3.2%',
        up: false,
        icon: ShoppingCart,
        iconBg: 'bg-purple-100',
        iconColor: 'text-purple-600',
        accent: 'from-purple-500 to-purple-600',
      },
      {
        label: 'Growth Rate',
        value: '24.6%',
        change: '+4.9%',
        up: true,
        icon: TrendingUp,
        iconBg: 'bg-emerald-100',
        iconColor: 'text-emerald-600',
        accent: 'from-emerald-500 to-emerald-600',
      },
    ];

    const navItems = [
      { label: 'Dashboard', icon: LayoutDashboard, active: true },
      { label: 'Profile', icon: User, active: false },
      { label: 'Settings', icon: Settings, active: false },
    ];

    const HomePage: React.FC = () => {
      const dispatch = useDispatch();
      const user = useSelector((state: RootState) => state.user.user);
      const [dropdownOpen, setDropdownOpen] = useState(false);
      const dropdownRef = useRef<HTMLDivElement>(null);

      const handleLogout = () => {
        dispatch(logoutUser() as any);
      };

      const initials = user?.email
        ? user.email.slice(0, 2).toUpperCase()
        : 'U';

      const today = new Date().toLocaleDateString('en-US', {
        weekday: 'long', month: 'long', day: 'numeric',
      });

      useEffect(() => {
        const handleClickOutside = (e: MouseEvent) => {
          if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
            setDropdownOpen(false);
          }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
      }, []);

      return (
        <div className="flex h-screen bg-gray-50">
          {/* Sidebar */}
          <aside className="w-64 bg-gray-900 text-white flex flex-col shadow-xl">
            {/* Logo */}
            <div className="h-16 flex items-center gap-3 px-5 border-b border-gray-700/60">
              <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-blue-600 shadow-lg shadow-blue-900/50">
                <Zap className="w-4 h-4 text-white" />
              </div>
              <span className="text-lg font-bold tracking-tight">AppName</span>
            </div>

            {/* Nav */}
            <nav className="flex-1 px-3 py-5 space-y-1">
              {navItems.map(({ label, icon: Icon, active }) => (
                <a
                  key={label}
                  href="#"
                  className={`flex items-center px-3 py-2.5 rounded-lg text-sm font-medium transition-colors duration-150 ${
                    active
                      ? 'bg-blue-600 text-white shadow-md shadow-blue-900/40'
                      : 'text-gray-400 hover:bg-gray-800 hover:text-white'
                  }`}
                >
                  <Icon className="w-4.5 h-4.5 mr-3 shrink-0" />
                  {label}
                </a>
              ))}
            </nav>

          </aside>

          {/* Main content */}
          <div className="flex-1 flex flex-col overflow-hidden">
            {/* Header */}
            <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 shadow-sm shrink-0">
              <div>
                <h1 className="text-lg font-semibold text-gray-900 leading-tight">Dashboard Overview</h1>
                <p className="text-xs text-gray-400">{today}</p>
              </div>
              <div className="flex items-center gap-4">
                {/* Notification bell */}
                <button className="relative p-2 rounded-lg text-gray-500 hover:bg-gray-100 hover:text-gray-700 transition-colors duration-150">
                  <Bell className="w-5 h-5" />
                  <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-red-500 rounded-full ring-2 ring-white" />
                </button>

                {/* User pill + dropdown */}
                <div className="relative" ref={dropdownRef}>
                  <button
                    onClick={() => setDropdownOpen((prev) => !prev)}
                    className="flex items-center gap-2.5 pl-1 pr-3 py-1.5 rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors duration-150"
                  >
                    <div className="flex items-center justify-center w-7 h-7 rounded-lg bg-blue-600 text-xs font-bold text-white shrink-0">
                      {initials}
                    </div>
                    <div className="flex flex-col items-start min-w-0">
                      <span className="text-sm font-medium text-gray-700 max-w-[140px] truncate leading-tight">{user?.email}</span>
                      <span className="text-[10px] font-semibold text-blue-600 bg-blue-50 px-1.5 py-px rounded-full leading-tight tracking-wide">Administrator</span>
                    </div>
                    <ChevronDown className={`w-4 h-4 text-gray-400 shrink-0 transition-transform duration-150 ${dropdownOpen ? 'rotate-180' : ''}`} />
                  </button>

                  {/* Dropdown panel */}
                  {dropdownOpen && (
                    <div className="absolute right-0 mt-2 w-52 bg-white rounded-xl border border-gray-200 shadow-lg shadow-gray-200/60 overflow-hidden z-50">
                      {/* Account info header */}
                      <div className="px-4 py-3 border-b border-gray-100">
                        <p className="text-xs text-gray-400">Signed in as</p>
                        <p className="text-sm font-medium text-gray-800 truncate">{user?.email}</p>
                      </div>

                      {/* Menu items */}
                      <div className="py-1">
                        <button className="flex items-center w-full gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150">
                          <User className="w-4 h-4 text-gray-400 shrink-0" />
                          Profile
                        </button>
                        <button className="flex items-center w-full gap-3 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150">
                          <Settings className="w-4 h-4 text-gray-400 shrink-0" />
                          Settings
                        </button>
                      </div>

                      {/* Divider + Sign out */}
                      <div className="border-t border-gray-100 py-1">
                        <button
                          onClick={handleLogout}
                          className="flex items-center w-full gap-3 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors duration-150"
                        >
                          <LogOut className="w-4 h-4 shrink-0" />
                          Sign out
                        </button>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            </header>

            {/* Content area */}
            <main className="flex-1 overflow-y-auto p-6 space-y-6">
              {/* Welcome banner */}
              <div>
                <h2 className="text-2xl font-bold text-gray-900">Good morning 👋</h2>
                <p className="text-sm text-gray-500 mt-0.5">Here's what's happening with your projects today.</p>
              </div>

              {/* Stat cards */}
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                {statCards.map(({ label, value, change, up, icon: Icon, iconBg, iconColor, accent }) => (
                  <div
                    key={label}
                    className="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 hover:shadow-md transition-shadow duration-200"
                  >
                    <div className="flex items-start justify-between">
                      <div className={`p-2.5 rounded-xl ${iconBg}`}>
                        <Icon className={`w-5 h-5 ${iconColor}`} />
                      </div>
                      <span
                        className={`inline-flex items-center gap-0.5 text-xs font-semibold px-2 py-0.5 rounded-full ${
                          up
                            ? 'bg-emerald-50 text-emerald-600'
                            : 'bg-red-50 text-red-500'
                        }`}
                      >
                        {up ? <ArrowUpRight className="w-3 h-3" /> : <ArrowDownRight className="w-3 h-3" />}
                        {change}
                      </span>
                    </div>
                    <div className="mt-4">
                      <p className="text-2xl font-bold text-gray-900">{value}</p>
                      <p className="text-sm text-gray-500 mt-0.5">{label}</p>
                    </div>
                    <div className={`mt-4 h-1 w-full rounded-full bg-gradient-to-r ${accent} opacity-70`} />
                  </div>
                ))}
              </div>

              {/* Placeholder content block */}
              <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                <div className="flex items-center justify-between mb-4">
                  <h3 className="text-base font-semibold text-gray-900">Recent Activity</h3>
                  <button className="text-xs font-medium text-blue-600 hover:text-blue-700 transition-colors duration-150">
                    View all
                  </button>
                </div>
                <div className="space-y-3">
                  {['New user registered', 'Order #1042 completed', 'Monthly report generated', 'System backup succeeded'].map((item, i) => (
                    <div key={i} className="flex items-center gap-3 py-2 border-b border-gray-50 last:border-0">
                      <div className="w-2 h-2 rounded-full bg-blue-500 shrink-0" />
                      <p className="text-sm text-gray-600">{item}</p>
                      <span className="ml-auto text-xs text-gray-400">{i + 1}h ago</span>
                    </div>
                  ))}
                </div>
              </div>
            </main>
          </div>
        </div>
      );
    };

    export default HomePage;
  TSX
end

# ── Rails backend ─────────────────────────────────────────────
say "== Setting up Rails backend ==", :green

# ApplicationController
remove_file "app/controllers/application_controller.rb"
create_file "app/controllers/application_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class ApplicationController < ActionController::Base
      skip_before_action :verify_authenticity_token
    end
  RUBY
end

# RootController
create_file "app/controllers/root_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class RootController < ApplicationController
      def index
      end
    end
  RUBY
end

create_file "app/views/root/index.html.erb", ""

# API controllers
empty_directory "app/controllers/api/v1/users"

create_file "app/controllers/api/v1/users/sessions_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class Api::V1::Users::SessionsController < Devise::SessionsController
      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)

        render json: {
          status: { 
            code: 200, message: 'Logged in successfully.',
            data: { user: UserBlueprint.render_as_hash(current_user) }
          }
        }, status: :ok
      end

      def destroy
        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        
        if signed_out
          render json: {
            status: 200,
            message: 'Logged out successfully.'
          }, status: :ok
        else
          render json: {
            status: 422,
            message: "There was a problem logging out."
          }, status: :unproccessable_entity
        end
      end
      
      def respond_with(current_user, _opts = {})
        render json: {
          status: { 
            code: 200, message: 'Logged in successfully.',
            data: { user: UserBlueprint.render_as_hash(current_user) }
          }
        }, status: :ok
      end

      # Add token validation endpoint
      def validate_token
        if current_user
          render json: {
            status: { 
              code: 200, message: 'Token is valid.',
              data: { user: UserBlueprint.render_as_hash(current_user) }
            }
          }, status: :ok
        else
          render json: {
            status: 401,
            message: "Invalid or expired token."
          }, status: :unauthorized
        end
      end
    end
  RUBY
end

create_file "app/controllers/api/v1/users/registrations_controller.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
      def respond_with(current_user, _opts = {})
        if resource.persisted?
          render json: {
            status: {code: 200, message: 'Signed up successfully.'},
            data: UserBlueprint.render_as_hash(current_user)
          }
        else
          render json: {
            message: "User couldn't be created successfully. \#{current_user.errors.full_messages.to_sentence}"
          }, status: :unprocessable_entity
        end
      end
    end
  RUBY
end

# Blueprint
empty_directory "app/blueprints"
create_file "app/blueprints/user_blueprint.rb" do
  <<~RUBY
    # frozen_string_literal: true
    class UserBlueprint < Blueprinter::Base
      identifier :id

      fields :email
    end
  RUBY
end

# ── Phase 1 routes: skeleton only — no devise_for, no draw(:api) ──
# Generators (devise:install, devise User) boot Rails to introspect routes.
# If devise_for :users or draw(:api) are present at that point, Rails calls
# const_get('User') before the model exists and crashes. The full routes are
# written in after_bundle (Phase 2) once the User model and DB are ready.
remove_file "config/routes.rb"
create_file "config/routes.rb" do
  <<~RUBY
    # frozen_string_literal: true

    Rails.application.routes.draw do
      get 'up' => 'rails/health#show', as: :rails_health_check
    end
  RUBY
end

empty_directory "config/routes"

# CORS initializer
create_file "config/initializers/cors.rb" do
  <<~RUBY
    Rails.application.config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # later change to the domain of the frontend app
        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 expose: [:Authorization]
      end
    end
  RUBY
end

# RSwag initializers
create_file "config/initializers/rswag_api.rb" do
  <<~RUBY
    Rswag::Api.configure do |c|

      # Specify a root folder where Swagger JSON files are located
      # This is used by the Swagger middleware to serve requests for API descriptions
      # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
      # that it's configured to generate files in the same folder
      c.openapi_root = Rails.root.to_s + '/swagger'

      # Inject a lambda function to alter the returned Swagger prior to serialization
      # The function will have access to the rack env for the current request
      # For example, you could leverage this to dynamically assign the "host" property
      #
      #c.swagger_filter = lambda { |swagger, env| swagger['host'] = env['HTTP_HOST'] }
    end
  RUBY
end

create_file "config/initializers/rswag_ui.rb" do
  <<~RUBY
    Rswag::Ui.configure do |c|

      # List the Swagger endpoints that you want to be documented through the
      # swagger-ui. The first parameter is the path (absolute or relative to the UI
      # host) to the corresponding endpoint and the second is a title that will be
      # displayed in the document selector.
      # NOTE: If you're using rspec-api to expose Swagger files
      # (under openapi_root) as JSON or YAML endpoints, then the list below should
      # correspond to the relative paths for those endpoints.

      c.swagger_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'

      # Add Basic Auth in case your API is private
      # c.basic_auth_enabled = true
      # c.basic_auth_credentials 'username', 'password'
    end
  RUBY
end

# ── Devise + JWT ──────────────────────────────────────────────
say "== Installing Devise ==", :green
run "bundle exec rails generate devise:install"

say "== Generating User model with Devise ==", :green
run "bundle exec rails generate devise User"

# Add JTI to users
run "bundle exec rails generate migration AddJtiToUsers jti:string:uniq:not_null"

# Overwrite User model with JWT support
remove_file "app/models/user.rb"
create_file "app/models/user.rb" do
  <<~RUBY
    # frozen_string_literal: true

    class User < ApplicationRecord
      # Include default devise modules. Others available are:
      # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
      include Devise::JWT::RevocationStrategies::JTIMatcher
      
      devise :database_authenticatable, :registerable,
             :recoverable, :rememberable, :validatable,
             :jwt_authenticatable, jwt_revocation_strategy: self

      validates :email, presence: true
    end
  RUBY
end

# ── Phase 2 routes: written immediately after generators ─────
# Devise generators are done — User model exists on disk.
# Overwrite the skeleton routes.rb and write config/routes/*.rb now,
# in the main template body (not after_bundle) so they are reliably applied.
say "== Writing full routes (Phase 2) ==", :green

create_file "config/routes.rb", force: true do
  <<~RUBY
    # frozen_string_literal: true

    Rails.application.routes.draw do
      mount Rswag::Api::Engine => '/api-docs'
      mount Rswag::Ui::Engine => '/api-docs'
      draw(:api)

      get 'up' => 'rails/health#show', as: :rails_health_check

      get '/*anyPath', to: 'root#index', anyPath: /(?!api).*/
    end
  RUBY
end

create_file "config/routes/api.rb" do
  <<~RUBY
    # frozen_string_literal: true

    namespace :api do
      draw(:v1)
    end
  RUBY
end

create_file "config/routes/v1.rb" do
  <<~RUBY
    # frozen_string_literal: true

    namespace :v1 do
      draw(:devise)
    end
  RUBY
end

create_file "config/routes/devise.rb" do
  <<~RUBY
    # frozen_string_literal: true

    devise_for :users, singular: :user, controllers: {
      registrations: 'api/v1/users/registrations',
      sessions: 'api/v1/users/sessions'
    }

    # Add custom route for token validation
    devise_scope :user do
      get 'users/validate_token', to: 'users/sessions#validate_token'
    end
  RUBY
end

# ── RSpec ─────────────────────────────────────────────────────
say "== Installing RSpec ==", :green
run "bundle exec rails generate rspec:install"

# rails_helper additions
inject_into_file "spec/rails_helper.rb", after: "require 'rspec/rails'\n" do
  <<~RUBY
    require_relative 'support/factory_bot'
    require_relative 'support/shoulda_matchers'
  RUBY
end

inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do
  "  config.include Devise::Test::IntegrationHelpers, type: :request\n"
end

# Support files
empty_directory "spec/support"
create_file "spec/support/factory_bot.rb" do
  <<~RUBY
    # frozen_string_literal: true
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY
end

create_file "spec/support/shoulda_matchers.rb" do
  <<~RUBY
    # frozen_string_literal: true
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  RUBY
end

# User factory
create_file "spec/factories/users.rb" do
  <<~RUBY
    # frozen_string_literal: true

    FactoryBot.define do
      factory :user do
        email { Faker::Internet.email }
        password { SecureRandom.hex }
      end
    end
  RUBY
end

# User model spec
create_file "spec/models/user_spec.rb" do
  <<~RUBY
    # frozen_string_literal: true

    require 'rails_helper'

    RSpec.describe User do
      describe '#validations' do
        it { is_expected.to validate_presence_of(:email) }
      end
    end
  RUBY
end

# ── Swagger scaffold ──────────────────────────────────────────
empty_directory "swagger/v1"
create_file "swagger/v1/swagger.yaml" do
  <<~YAML
    ---
    openapi: 3.0.1
    info:
      title: API V1
      version: v1
    paths:
      "/api/v1/users":
        post:
          summary: registers new users
          tags:
          - Registrations
          parameters: []
          responses:
            '200':
              description: register new user successfully
            '422':
              description: registration failed because user already exists
          requestBody:
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    email:
                      type: string
                    password:
                      type: string
                    password_confirmation:
                      type: string
      "/api/v1/users/sign_in":
        post:
          summary: creates new user session
          tags:
          - Sessions
          parameters: []
          responses:
            '200':
              description: logins new user successfully
          requestBody:
            content:
              application/json:
                schema:
                  type: object
                  properties:
                    email:
                      type: string
                    password:
                      type: string
      "/api/v1/users/sign_out":
        delete:
          summary: logs out user
          tags:
          - Sessions
          parameters:
          - name: Authorization
            in: header
            schema:
              type: string
          responses:
            '200':
              description: logins new user successfully
    servers:
    - url: https://{defaultHost}
      variables:
        defaultHost:
          default: www.example.com
  YAML
end

# ── DB + credentials + JWT config ────────────────────────────
# Strict order required:
#   1. DB created + migrated — migrations are on disk, no initializer JWT yet
#   2. Credential written — no KeyError when initializer loads next
#   3. JWT config appended — bang method safe, credential is present
say "== Creating and migrating database ==", :green
rails_command "db:create db:migrate"

say "== Writing devise_jwt_secret_key credential ==", :green
rails_command "runner \"Rails.application.credentials.tap { |c| c[:devise_jwt_secret_key] = SecureRandom.hex(64) }.write\""

say "== Appending JWT config to Devise initializer ==", :green
append_to_file "config/initializers/devise.rb" do
  <<~RUBY

    Devise.setup do |config|
      config.jwt do |jwt|
        jwt.secret = Rails.application.credentials.devise_jwt_secret_key!
        jwt.dispatch_requests = [
          ['POST', %r{^/login$}]
        ]
        jwt.revocation_requests = [
          ['DELETE', %r{^/logout$}]
        ]
        jwt.expiration_time = 5.minutes.to_i
      end
    end
  RUBY
end

# ── Final instructions ────────────────────────────────────────
say "", :green
say "================================================================", :green
say "  Template applied successfully!", :green
say "================================================================", :green
say ""
say "Next steps:"
say "  1. Start the dev server:"
say "     bin/dev  (requires Foreman: gem install foreman)"
say "  2. Rename the app:"
say "     rails app:rename[MyNewAppName]"
say ""
say "  (db:create, db:migrate, and credentials were set up automatically)"
say ""
say "URLs:"
say "  App:     http://localhost:3000"
say "  API docs: http://localhost:3000/api-docs"
say ""
