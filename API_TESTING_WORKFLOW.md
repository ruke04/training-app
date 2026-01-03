# API Testing Workflow Diagram

## Complete API Testing Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    API TESTING WORKFLOW                         │
└─────────────────────────────────────────────────────────────────┘

┌──────────────┐
│  1. SETUP    │
│              │
│ • Start App  │
│ • Open       │
│   Postman    │
│ • Create     │
│   Collection │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  2. ENVIRONMENT SETUP                                        │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  Environment: "Training App Local"         │            │
│  │  ────────────────────────────────────────  │            │
│  │  base_url: http://localhost:8080/api     │            │
│  │  token: (empty - will be set auto)       │            │
│  │  username: testuser                      │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  3. AUTHENTICATION FLOW                                      │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  POST /api/register                       │            │
│  │  Body: {username, password}               │            │
│  │  ────────────────────────────────────────  │            │
│  │  Response: {token: "..."}                │            │
│  │  ✅ Save token to environment            │            │
│  └────────────────────────────────────────────┘            │
│                    │                                        │
│                    ▼                                        │
│  ┌────────────────────────────────────────────┐            │
│  │  POST /api/login                          │            │
│  │  Body: {username, password}               │            │
│  │  ────────────────────────────────────────  │            │
│  │  Response: {token: "..."}                │            │
│  │  ✅ Verify token received                 │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  4. PROTECTED ENDPOINTS TESTING                              │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  GET /api/me                               │            │
│  │  Headers: Authorization: Bearer {{token}} │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Status: 200                            │            │
│  │  ✅ Response: {username: "testuser"}      │            │
│  └────────────────────────────────────────────┘            │
│                    │                                        │
│                    ▼                                        │
│  ┌────────────────────────────────────────────┐            │
│  │  GET /api/users                            │            │
│  │  Headers: Authorization: Bearer {{token}} │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Status: 200                            │            │
│  │  ✅ Response: Array of users              │            │
│  │  ✅ Validate structure                    │            │
│  └────────────────────────────────────────────┘            │
│                    │                                        │
│                    ▼                                        │
│  ┌────────────────────────────────────────────┐            │
│  │  PUT /api/me/password                     │            │
│  │  Body: {current_password, new_password}   │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Status: 200                            │            │
│  │  ✅ Password changed                       │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  5. ERROR HANDLING TESTS                                     │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  Test: Missing Token                      │            │
│  │  GET /api/me (no Authorization header)    │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Expected: 401 Unauthorized             │            │
│  └────────────────────────────────────────────┘            │
│                    │                                        │
│                    ▼                                        │
│  ┌────────────────────────────────────────────┐            │
│  │  Test: Invalid Credentials                 │            │
│  │  POST /api/login                          │            │
│  │  Body: {username: "wrong", password: "x"} │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Expected: 401 Unauthorized             │            │
│  └────────────────────────────────────────────┘            │
│                    │                                        │
│                    ▼                                        │
│  ┌────────────────────────────────────────────┐            │
│  │  Test: Duplicate Registration             │            │
│  │  POST /api/register (existing user)       │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✅ Expected: 409 Conflict                 │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  6. TEST ASSERTIONS                                          │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  pm.test("Status code is 200", ...)       │            │
│  │  pm.test("Response has token", ...)       │            │
│  │  pm.test("Response time < 500ms", ...)    │            │
│  │  pm.test("JSON structure valid", ...)     │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  7. COLLECTION RUNNER                                        │
│                                                              │
│  ┌────────────────────────────────────────────┐            │
│  │  Run Collection: "Training App API"        │            │
│  │  ────────────────────────────────────────  │            │
│  │  ✓ Register User (45ms)                   │            │
│  │  ✓ Login (32ms)                           │            │
│  │  ✓ Get Current User (28ms)                │            │
│  │  ✓ List All Users (67ms)                  │            │
│  │  ✓ Change Password (41ms)                 │            │
│  │  ✗ Delete User (401)                      │            │
│  │                                            │            │
│  │  Summary: 5 passed, 1 failed                │            │
│  └────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│  8. RESULTS & REPORTING                                      │
│                                                              │
│  • View test results                                         │
│  • Export collection                                         │
│  • Share with team                                           │
│  • Integrate with CI/CD                                      │
└─────────────────────────────────────────────────────────────┘
```

## Request-Response Flow

```
┌──────────┐         ┌──────────┐         ┌──────────┐
│  Client  │────────▶│  API     │────────▶│ Database │
│ (Postman)│ Request │ (Backend)│ Query   │          │
└──────────┘         └──────────┘         └──────────┘
     │                     │                     │
     │                     │                     │
     │                     │                     │
     │                     ▼                     │
     │              ┌──────────┐                │
     │              │ Process  │                │
     │              │ Business │                │
     │              │  Logic   │                │
     │              └──────────┘                │
     │                     │                     │
     │                     │                     │
     │                     ▼                     │
     │              ┌──────────┐                │
     │              │ Response │                │
     │              │   JSON   │                │
     │              └──────────┘                │
     │                     │                     │
     │                     │                     │
     ▼                     ▼                     ▼
┌──────────┐         ┌──────────┐         ┌──────────┐
│ Validate │◀────────│  Client  │         │  Update  │
│ Response │ Response│ (Postman)│         │   Data   │
└──────────┘         └──────────┘         └──────────┘
```

## Authentication Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION FLOW                      │
└─────────────────────────────────────────────────────────────┘

Step 1: Register
┌──────────────┐    POST /api/register    ┌──────────────┐
│   Client     │ ────────────────────────▶ │   Server     │
│              │  {username, password}     │              │
└──────────────┘                           └──────────────┘
       │                                           │
       │                                           │ Create User
       │                                           │ Generate JWT
       │                                           │
       │    {token: "eyJhbGc..."}                 │
       │◀──────────────────────────────────────────│
       │                                           │
       │ Save token                                │
       ▼                                           ▼

Step 2: Use Token
┌──────────────┐    GET /api/me            ┌──────────────┐
│   Client     │ ────────────────────────▶ │   Server     │
│              │  Authorization: Bearer    │              │
│              │  {token}                  │              │
└──────────────┘                           └──────────────┘
       │                                           │
       │                                           │ Verify Token
       │                                           │ Extract User
       │                                           │
       │    {username: "testuser"}                │
       │◀──────────────────────────────────────────│
       │                                           │
       ▼                                           ▼
```

## Test Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│              POSTMAN COLLECTION EXECUTION                    │
└─────────────────────────────────────────────────────────────┘

Start Collection
       │
       ▼
┌─────────────────┐
│ Pre-request     │  Set variables, generate data
│ Script          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Send Request    │  HTTP Request to API
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Receive         │  Get Response from Server
│ Response        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Run Tests       │  Execute Assertions
│ (Assertions)    │  • Status code
│                 │  • Response structure
│                 │  • Data validation
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Post-request    │  Save token, update vars
│ Script          │
└────────┬────────┘
         │
         ▼
    Next Request?
         │
    Yes──┴──No
         │
         ▼
    Generate Report
```

## Training App API Endpoints Map

```
┌─────────────────────────────────────────────────────────────┐
│              TRAINING APP API STRUCTURE                     │
└─────────────────────────────────────────────────────────────┘

Base URL: http://localhost:8080/api
         │
         ├─── POST /register ────────────────┐
         │                                    │
         ├─── POST /login ───────────────────┤
         │                                    │
         ├─── GET  /me ──────────────────────┤  Protected
         │                                    │  (Requires Token)
         ├─── GET  /users ───────────────────┤
         │                                    │
         ├─── PUT  /me/password ─────────────┤
         │                                    │
         ├─── DELETE /users/{username} ──────┤
         │                                    │
         └─── DELETE /me ────────────────────┘

Authentication:
  • Register/Login → Get Token
  • Use Token in Authorization Header
  • Format: Bearer {token}
```
