# Rails + React + Redux + JWT Auth Template

A production-ready full-stack starter template. Use it as a GitHub template repository or apply it to a fresh Rails app with a single command.

## Stack

| Layer | Technology |
|---|---|
| Backend | Rails 7.1, PostgreSQL, Puma |
| Authentication | Devise + devise-jwt (JTI revocation) |
| Serialization | Blueprinter |
| API docs | RSwag (Swagger/OpenAPI) |
| Frontend build | Vite + vite_rails |
| UI framework | React 18 + TypeScript |
| State management | Redux Toolkit |
| Routing | React Router v7 |
| Styling | Tailwind CSS v4 |
| Testing | RSpec, FactoryBot, Faker, Shoulda Matchers |

---

## Option A — Use as a GitHub Template (fastest)

1. Click **"Use this template"** on the GitHub repo page
2. Clone your new repo
3. Follow the setup steps below

---

## Option B — Apply as a Rails Template

```bash
rails new myapp -d postgresql -m https://raw.githubusercontent.com/YOUR_USERNAME/rails_with_redux_and_jwt_auth/main/template.rb
```

Or from a local clone:

```bash
rails new myapp -d postgresql -m /path/to/rails_with_redux_and_jwt_auth/template.rb
```

> **Prerequisites:** Ruby 3.2+, Rails 7.1+, Node.js 18+, Yarn, PostgreSQL

---

## Setup (after cloning or template apply)

### 1. Install dependencies

```bash
bundle install
yarn install
```

### 2. Configure credentials

The JWT secret must live in Rails encrypted credentials:

```bash
rails credentials:edit
```

Add this block:

```yaml
devise_jwt_secret_key: <paste output of `rails secret` here>
```

### 3. Configure the database

Edit `config/database.yml` with your PostgreSQL credentials, then:

```bash
rails db:create db:migrate
```

### 4. Start the dev server

Install Foreman if you haven't:

```bash
gem install foreman
```

Then start both Rails and Vite with one command:

```bash
bin/dev
```

| Service | URL |
|---|---|
| App | http://localhost:3000 |
| API docs (Swagger) | http://localhost:3000/api-docs |

---

## Rename the App

The template ships with the placeholder name `RailsTemplate`. To rename:

```bash
rails app:rename[YourNewAppName]
```

This updates `config/application.rb`, the layout title, and module names via the `rename` gem.

---

## Project Structure

```
.
├── app/
│   ├── blueprints/
│   │   └── user_blueprint.rb          # JSON serializer for User
│   ├── controllers/
│   │   ├── api/v1/users/
│   │   │   ├── sessions_controller.rb  # Login / logout / token validation
│   │   │   └── registrations_controller.rb
│   │   ├── application_controller.rb
│   │   └── root_controller.rb          # Serves the React SPA
│   ├── frontend/                        # All React/TypeScript code lives here
│   │   ├── assets/styles/tailwind.css
│   │   ├── components/
│   │   │   ├── ProtectedRoute.tsx       # Auth guard component
│   │   │   └── auth/LoginForm.tsx
│   │   ├── entrypoints/
│   │   │   └── application.tsx          # Vite entry — mounts React + Redux
│   │   ├── interfaces/state/userState.tsx
│   │   ├── pages/
│   │   │   ├── home/index.tsx           # Dashboard (protected)
│   │   │   └── login/index.tsx
│   │   ├── routes/index.tsx             # React Router setup
│   │   ├── services/
│   │   │   ├── authService.ts           # fetch wrappers for auth API
│   │   │   └── tokenStorage.ts          # AES-GCM encrypted localStorage/sessionStorage
│   │   ├── state/
│   │   │   ├── store.tsx                # Redux store
│   │   │   └── user/userSlice.tsx       # User slice + async thunks
│   │   └── App.tsx
│   ├── models/user.rb
│   └── views/layouts/application.html.erb
├── config/
│   ├── initializers/
│   │   ├── cors.rb
│   │   ├── devise.rb                    # JWT config appended here
│   │   ├── rswag_api.rb
│   │   └── rswag_ui.rb
│   └── routes/
│       ├── api.rb
│       ├── devise.rb
│       └── v1.rb
├── spec/
│   ├── factories/users.rb
│   ├── models/user_spec.rb
│   └── support/
│       ├── factory_bot.rb
│       └── shoulda_matchers.rb
├── swagger/v1/swagger.yaml
├── template.rb                          # Rails application template
├── vite.config.ts
├── tsconfig.json
├── tailwind.config.js
└── Procfile.dev
```

---

## Authentication Flow

```
POST /api/v1/users/sign_in   { user: { email, password } }
  → 200 + JWT in Authorization header + user JSON

DELETE /api/v1/users/sign_out
  → 200, JWT revoked via JTI column

GET /api/v1/users/validate_token   (Authorization: Bearer <token>)
  → 200 if valid, 401 if expired/invalid
```

**Frontend flow:**

1. On app mount, `checkAuthStatus` thunk reads the stored token and calls `validate_token`
2. If valid → Redux `isSignedIn: true`, user accesses protected routes
3. If invalid/missing → redirect to `/login`
4. On login, JWT is stored in `localStorage` (remember me) or `sessionStorage` (session only)
5. On logout, token is cleared from storage and revoked on the server via JTI

---

## API Endpoints

| Method | Path | Description |
|---|---|---|
| `POST` | `/api/v1/users/sign_in` | Login — returns JWT |
| `DELETE` | `/api/v1/users/sign_out` | Logout — revokes JWT |
| `POST` | `/api/v1/users` | Register new user |
| `GET` | `/api/v1/users/validate_token` | Validate existing JWT |
| `GET` | `/api-docs` | Swagger UI |
| `GET` | `/up` | Health check |

---

## Adding New API Endpoints

### 1. Add a route

```ruby
# config/routes/v1.rb
namespace :v1 do
  draw(:devise)
  resources :posts, only: [:index, :create, :show]
end
```

### 2. Create a controller

```ruby
# app/controllers/api/v1/posts_controller.rb
class Api::V1::PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: { posts: PostBlueprint.render_as_hash(Post.all) }
  end
end
```

### 3. Add a blueprint serializer

```ruby
# app/blueprints/post_blueprint.rb
class PostBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :body, :created_at
end
```

### 4. Call it from the frontend

```typescript
// app/frontend/services/postService.ts
const token = await tokenStorage.getToken();
const response = await fetch('/api/v1/posts', {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

---

## Adding New Redux State

```typescript
// app/frontend/state/posts/postsSlice.tsx
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';

export const fetchPosts = createAsyncThunk('posts/fetch', async () => {
  const response = await fetch('/api/v1/posts');
  return response.json();
});

const postsSlice = createSlice({
  name: 'posts',
  initialState: { items: [], isLoading: false },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchPosts.fulfilled, (state, action) => {
      state.items = action.payload.posts;
    });
  }
});

export default postsSlice.reducer;
```

Register in the store:

```typescript
// app/frontend/state/store.tsx
import postsReducer from './posts/postsSlice';

export const store = configureStore({
  reducer: {
    user: userReducer,
    posts: postsReducer,  // add here
  }
});
```

---

## Adding New Pages

```typescript
// app/frontend/pages/settings/index.tsx
const SettingsPage: React.FC = () => <div>Settings</div>;
export default SettingsPage;
```

Register in routes:

```typescript
// app/frontend/routes/index.tsx
import SettingsPage from '../pages/settings';

<Route path='/settings' element={
  <ProtectedRoute><SettingsPage /></ProtectedRoute>
} />
```

---

## Running Tests

```bash
# All specs
bundle exec rspec

# Single file
bundle exec rspec spec/models/user_spec.rb

# With documentation format
bundle exec rspec --format documentation
```

---

## Generating Swagger Docs

```bash
bundle exec rake rswag:specs:swaggerize
```

The generated file lands at `swagger/v1/swagger.yaml` and is served at `/api-docs`.

---

## Credentials Reference

All secrets use Rails encrypted credentials (`config/credentials.yml.enc`). Edit with:

```bash
rails credentials:edit
```

Required keys:

```yaml
secret_key_base: ...          # auto-generated by Rails
devise_jwt_secret_key: ...    # generate with `rails secret`
```

For production, set the `RAILS_MASTER_KEY` environment variable.

---

## Production Checklist

- [ ] Set `ALLOWED_ORIGINS` (comma-separated frontend domains) — CORS defaults to `*` for dev
- [ ] Set `JWT_EXPIRATION_MINUTES` to an appropriate value — defaults to `60`
- [ ] Set `RAILS_MASTER_KEY` in your deployment environment
- [ ] Configure a production database in `config/database.yml`
- [ ] Set `RAILS_ENV=production`
- [ ] Run `bundle exec vite build` for production assets (or configure your CI to do it)

---

## Tech Reference

- [Devise](https://github.com/heartcombo/devise)
- [devise-jwt](https://github.com/waiting-for-dev/devise-jwt)
- [vite_rails](https://vite-ruby.netlify.app/guide/rails.html)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [React Router](https://reactrouter.com/)
- [Tailwind CSS](https://tailwindcss.com/)
- [RSwag](https://github.com/rswag/rswag)
- [Blueprinter](https://github.com/procore-oss/blueprinter)
