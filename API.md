### REST API Documentation

- Base URL: `http://localhost:8000`
- Content-Type: `application/json` unless otherwise noted
- Auth: Bearer JWT in `Authorization` header for protected routes (or `?token=`/`auth_token` cookie for protected static site endpoints)

### Auth and Users

#### POST `/register`
- Create a new user and return a JWT
- Body: `{ "username": string, "password": string }`
- Responses:
  - `201 Created`: `{ "token": string }`
  - `409 Conflict`: `{ "detail": "Username already exists" }`
- Example:
  - `curl -i -X POST http://localhost:8000/register -H 'Content-Type: application/json' -d '{"username":"u1","password":"12345"}'`

#### POST `/login`
- Exchange valid credentials for a JWT
- Body: `{ "username": string, "password": string }`
- Responses:
  - `200 OK`: `{ "token": string }`
  - `401 Unauthorized`: `{ "detail": "Invalid credentials" }`
- Example:
  - `curl -i -X POST http://localhost:8000/login -H 'Content-Type: application/json' -d '{"username":"u1","password":"12345"}'`

#### GET `/me`
- Get current user identity from the JWT
- Auth: `Authorization: Bearer <token>`
- Responses:
  - `200 OK`: `{ "username": string }`
  - `401 Unauthorized`: `{ "detail": "Missing token" | "Invalid token" }`
- Example:
  - `curl -i http://localhost:8000/me -H "Authorization: Bearer TOKEN"`

### Protected Static Site Delivery

These endpoints serve files from the protected directory mounted at `/app/protected_site` and require a valid JWT. They accept the token via:
- `Authorization: Bearer <token>` header, or
- `?token=...` query parameter, or
- `auth_token` cookie (set when you visit `/protected` with a valid token)

#### GET `/protected`
- Serves `index.html` and sets the `auth_token` cookie
- Responses: `200 OK` on success; `401/404` on invalid token or missing file
- Example: `curl -i "http://localhost:8000/protected?token=TOKEN"`

#### GET `/protected/{path}`
- Serves a file under the protected directory (nested paths)
- Responses: `200 OK`, `400 Invalid path`, `404 Not found`

#### GET `/style.css` | `/script.js` | `/img/{asset}` | `/logos/{asset}`
- Serve root-relative assets referenced by the protected site
- Responses: `200 OK`, `404 Not found`

### Common Status Codes
- `200 OK`: Successful request
- `201 Created`: Resource created (e.g., user)
- `400 Bad Request`: Invalid path or request
- `401 Unauthorized`: Missing/invalid credentials
- `404 Not Found`: Resource/file missing
- `409 Conflict`: Duplicate username

### Quick Flow
1) Register to get a token:
   - `TOKEN=$(curl -s -X POST http://localhost:8000/register -H 'Content-Type: application/json' -d '{"username":"u1","password":"12345"}' | jq -r .token)`
2) Use the token with `/me`:
   - `curl -i http://localhost:8000/me -H "Authorization: Bearer $TOKEN"`
3) Open the protected site:
   - `open "http://localhost:8000/protected?token=$TOKEN"`


