# REST API Documentation

- Base URL: `http://localhost:8000` (direct) or `http://localhost:8080/api` (via Nginx proxy)
- Content-Type: `application/json`
- Auth: Bearer JWT in `Authorization` header for protected routes

## Authentication Endpoints

### POST `/register`
Create a new user and return a JWT token.

- **Body**: `{ "username": string, "password": string }`
- **Responses**:
  - `201 Created`: `{ "token": string }`
  - `409 Conflict`: `{ "detail": "Username already exists" }`

```bash
curl -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"12345"}'
```

### POST `/login`
Authenticate and receive a JWT token.

- **Body**: `{ "username": string, "password": string }`
- **Responses**:
  - `200 OK`: `{ "token": string }`
  - `401 Unauthorized`: `{ "detail": "Invalid credentials" }`

```bash
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"12345"}'
```

### POST `/logout` or GET `/logout`
Clear the `auth_token` cookie to log out.

- **Auth**: Not required
- **Responses**: `200 OK`

```bash
curl -X POST http://localhost:8080/api/logout
```

## User Endpoints

### GET `/me`
Get current user info from JWT.

- **Auth**: `Authorization: Bearer <token>`
- **Responses**:
  - `200 OK`: `{ "username": string }`
  - `401 Unauthorized`: Missing/invalid token

```bash
curl http://localhost:8080/api/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### GET `/users`
List all registered users.

- **Auth**: `Authorization: Bearer <token>`
- **Responses**:
  - `200 OK`: `[{ "id": int, "username": string, "created_at": string }, ...]`
  - `401 Unauthorized`: Missing/invalid token

```bash
curl http://localhost:8080/api/users \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### DELETE `/users/{username}`
Delete a user by username.

- **Auth**: `Authorization: Bearer <token>`
- **Responses**:
  - `200 OK`: `{ "message": "User deleted successfully" }`
  - `401 Unauthorized`: Missing/invalid token
  - `404 Not Found`: User not found

```bash
curl -X DELETE http://localhost:8080/api/users/someuser \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### DELETE `/me`
Delete the currently logged-in user's account.

- **Auth**: `Authorization: Bearer <token>`
- **Responses**:
  - `200 OK`: `{ "message": "Account deleted successfully" }`
  - `401 Unauthorized`: Missing/invalid token

```bash
curl -X DELETE http://localhost:8080/api/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### PUT `/me/password`
Change the current user's password.

- **Auth**: `Authorization: Bearer <token>`
- **Body**: `{ "current_password": string, "new_password": string }`
- **Responses**:
  - `200 OK`: `{ "message": "Password updated successfully" }`
  - `400 Bad Request`: Current password incorrect
  - `401 Unauthorized`: Missing/invalid token

```bash
curl -X PUT http://localhost:8080/api/me/password \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"current_password":"old123","new_password":"new456"}'
```

## Protected Static Site

These endpoints serve files from the protected directory and require authentication.

### GET `/protected`
Serve the protected site's `index.html` and set `auth_token` cookie.

- **Auth**: Bearer token, `?token=` query param, or `auth_token` cookie
- **Responses**: `200 OK`, `401 Unauthorized`, `404 Not Found`

```bash
curl "http://localhost:8000/protected?token=YOUR_TOKEN"
```

### GET `/protected/{path}`
Serve files from the protected directory.

- **Auth**: Same as `/protected`
- **Responses**: `200 OK`, `401 Unauthorized`, `404 Not Found`

### Static Assets
- `GET /style.css` - Protected site stylesheet
- `GET /script.js` - Protected site JavaScript
- `GET /img/{asset}` - Protected site images
- `GET /logos/{asset}` - Protected site logos

## API Documentation

### GET `/api-docs`
Swagger UI for interactive API documentation.

```bash
open http://localhost:8080/api/api-docs
```

## Status Codes

| Code | Description |
|------|-------------|
| `200` | Success |
| `201` | Created |
| `400` | Bad Request |
| `401` | Unauthorized |
| `404` | Not Found |
| `409` | Conflict (duplicate) |

## Quick Flow Example

```bash
# 1. Register
TOKEN=$(curl -s -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","password":"12345"}' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 2. Get profile
curl http://localhost:8080/api/me -H "Authorization: Bearer $TOKEN"

# 3. List users
curl http://localhost:8080/api/users -H "Authorization: Bearer $TOKEN"

# 4. Open protected site
open "http://localhost:8000/protected?token=$TOKEN"
```

## Nginx Proxy

The frontend Nginx server proxies `/api/*` requests to the backend:
- `http://localhost:8080/api/register` → `http://backend:8000/register`
- `http://localhost:8080/api/login` → `http://backend:8000/login`
- etc.

This eliminates CORS issues when accessing from any host/IP.
