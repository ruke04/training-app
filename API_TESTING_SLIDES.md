# API Testing: A Complete Guide
## Using the Training App as Example

---

## Slide 1: What is API Testing?

### API = Application Programming Interface

**Definition:**
- A set of protocols and tools for building software applications
- Allows different software components to communicate
- Acts as a contract between frontend and backend

**Why Test APIs?**
- ✅ Verify functionality without UI
- ✅ Faster than UI testing
- ✅ Test edge cases and error handling
- ✅ Ensure integration between services
- ✅ Validate data formats and responses

---

## Slide 2: Types of APIs

### 1. REST (Representational State Transfer)
**Characteristics:**
- Uses HTTP methods (GET, POST, PUT, DELETE)
- Stateless communication
- JSON/XML data format
- **Example:** Training App API

### 2. SOAP (Simple Object Access Protocol)
**Characteristics:**
- XML-based protocol
- More structured and formal
- Built-in security features

### 3. GraphQL
**Characteristics:**
- Query language for APIs
- Clients request only needed data
- Single endpoint for all operations

### 4. gRPC
**Characteristics:**
- High-performance RPC framework
- Uses Protocol Buffers
- Common in microservices

---

## Slide 3: REST API Methods

### HTTP Methods Overview

| Method | Purpose | Example |
|--------|---------|---------|
| **GET** | Retrieve data | Get user list |
| **POST** | Create new resource | Register user |
| **PUT** | Update resource | Change password |
| **DELETE** | Remove resource | Delete user |

### Training App Examples:
- `GET /api/users` - List all users
- `POST /api/register` - Create account
- `PUT /api/me/password` - Update password
- `DELETE /api/users/{username}` - Delete user

---

## Slide 4: API Testing Tools

### Popular Tools

1. **Postman** ⭐ (Most Popular)
   - GUI-based testing
   - Collection management
   - Environment variables
   - Automated testing

2. **cURL**
   - Command-line tool
   - Available everywhere
   - Script-friendly

3. **Insomnia**
   - Clean interface
   - Similar to Postman
   - Open source

4. **REST Assured** (Java)
   - Code-based testing
   - Integration with test frameworks

5. **Robot Framework**
   - Keyword-driven
   - API library support

---

## Slide 5: Introduction to Postman

### What is Postman?
- **GUI tool** for API testing
- **Collection** management
- **Environment** variables
- **Automated** test scripts
- **Documentation** generation
- **Mock servers**

### Key Features:
- ✅ Easy request building
- ✅ Save and organize requests
- ✅ Share with team
- ✅ Write test assertions
- ✅ Generate code snippets

---

## Slide 6: Postman Interface Overview

```
┌─────────────────────────────────────────┐
│  Postman                                │
├─────────────────────────────────────────┤
│  [Collections] [Environments] [History] │
├─────────────────────────────────────────┤
│  Method: [POST ▼]  URL: [____________] │
│  [Params] [Headers] [Body] [Tests]      │
├─────────────────────────────────────────┤
│  Body:                                  │
│  ○ none  ○ form-data  ○ x-www-form-url │
│  ● raw  ○ binary  ○ GraphQL             │
│  JSON ▼                                 │
│  {                                      │
│    "username": "testuser",              │
│    "password": "12345"                  │
│  }                                      │
├─────────────────────────────────────────┤
│  [Send]                                 │
└─────────────────────────────────────────┘
```

---

## Slide 7: Testing Registration Endpoint

### Training App: POST /api/register

**Step 1: Setup Request**
- Method: `POST`
- URL: `http://localhost:8080/api/register`
- Headers: `Content-Type: application/json`

**Step 2: Request Body**
```json
{
  "username": "john_doe",
  "password": "secure123"
}
```

**Step 3: Expected Response**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```
Status: `201 Created`

**Step 4: Test Error Case**
Same request with existing username → `409 Conflict`

---

## Slide 8: Postman Screenshot: Registration

### Visual Guide

**Request Tab:**
```
POST http://localhost:8080/api/register

Headers:
  Content-Type: application/json

Body (raw JSON):
{
  "username": "alice",
  "password": "password123"
}
```

**Response:**
```
Status: 201 Created
Time: 45ms
Size: 156 B

Body:
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

---

## Slide 9: Testing Login Endpoint

### Training App: POST /api/login

**Request:**
```http
POST http://localhost:8080/api/login
Content-Type: application/json

{
  "username": "john_doe",
  "password": "secure123"
}
```

**Success Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Error Response (401 Unauthorized):**
```json
{
  "detail": "Invalid credentials"
}
```

**Postman Tips:**
- Save token as environment variable
- Use in subsequent requests

---

## Slide 10: Using Environment Variables

### Postman Environments

**Create Environment:**
1. Click "Environments" → "Add"
2. Name: "Training App Local"
3. Add variables:
   - `base_url`: `http://localhost:8080/api`
   - `token`: (leave empty, will be set automatically)

**Use in Requests:**
```
URL: {{base_url}}/register
Authorization: Bearer {{token}}
```

**Set Token Automatically:**
In Tests tab:
```javascript
if (pm.response.code === 200 || pm.response.code === 201) {
    const jsonData = pm.response.json();
    if (jsonData.token) {
        pm.environment.set("token", jsonData.token);
    }
}
```

---

## Slide 11: Testing Protected Endpoints

### Training App: GET /api/me

**Request Setup:**
- Method: `GET`
- URL: `{{base_url}}/me`
- Authorization: `Bearer {{token}}`

**Headers:**
```
Authorization: Bearer {{token}}
```

**Success Response (200 OK):**
```json
{
  "username": "john_doe"
}
```

**Error Response (401 Unauthorized):**
```json
{
  "detail": "Not authenticated"
}
```

**Test Without Token:**
Remove Authorization header → Should get 401

---

## Slide 12: Testing User List Endpoint

### Training App: GET /api/users

**Request:**
```http
GET {{base_url}}/users
Authorization: Bearer {{token}}
```

**Success Response (200 OK):**
```json
[
  {
    "id": 1,
    "username": "john_doe",
    "created_at": "2025-12-28T10:30:00"
  },
  {
    "id": 2,
    "username": "alice",
    "created_at": "2025-12-28T11:15:00"
  }
]
```

**Postman Tests:**
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response is array", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.be.an('array');
});

pm.test("Users have required fields", function () {
    const jsonData = pm.response.json();
    jsonData.forEach(user => {
        pm.expect(user).to.have.property('id');
        pm.expect(user).to.have.property('username');
    });
});
```

---

## Slide 13: Testing DELETE Endpoint

### Training App: DELETE /api/users/{username}

**Request:**
```http
DELETE {{base_url}}/users/alice
Authorization: Bearer {{token}}
```

**Success Response (200 OK):**
```json
{
  "message": "User deleted successfully"
}
```

**Error Cases:**
- `401 Unauthorized` - No/invalid token
- `404 Not Found` - User doesn't exist

**Postman Test:**
```javascript
pm.test("User deleted successfully", function () {
    pm.response.to.have.status(200);
    const jsonData = pm.response.json();
    pm.expect(jsonData.message).to.include("deleted");
});
```

---

## Slide 14: Testing Password Change

### Training App: PUT /api/me/password

**Request:**
```http
PUT {{base_url}}/me/password
Authorization: Bearer {{token}}
Content-Type: application/json

{
  "current_password": "secure123",
  "new_password": "newsecure456"
}
```

**Success Response (200 OK):**
```json
{
  "message": "Password updated successfully"
}
```

**Error Response (400 Bad Request):**
```json
{
  "detail": "Current password is incorrect"
}
```

---

## Slide 15: Creating Postman Collections

### Organize Your Tests

**Collection Structure:**
```
Training App API
├── Authentication
│   ├── Register User
│   ├── Login
│   └── Logout
├── User Management
│   ├── Get Current User
│   ├── List All Users
│   ├── Delete User
│   └── Change Password
└── Protected Site
    └── Access Protected Content
```

**Benefits:**
- ✅ Organize related requests
- ✅ Run entire collection
- ✅ Share with team
- ✅ Export/Import easily

---

## Slide 16: Writing Postman Tests

### Automated Assertions

**Basic Tests:**
```javascript
// Status code check
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Response time check
pm.test("Response time is less than 500ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(500);
});

// JSON structure validation
pm.test("Response has token", function () {
    const jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('token');
});
```

**Advanced Tests:**
```javascript
// Save token automatically
if (pm.response.code === 201) {
    const jsonData = pm.response.json();
    pm.environment.set("token", jsonData.token);
}

// Validate token format (JWT)
pm.test("Token is valid JWT", function () {
    const jsonData = pm.response.json();
    const token = jsonData.token;
    pm.expect(token).to.match(/^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]*$/);
});
```

---

## Slide 17: Running Collections

### Automated Test Execution

**Run Collection:**
1. Click on collection name
2. Click "Run" button
3. Select requests to run
4. Click "Run Training App API"

**View Results:**
- ✅ Pass/Fail status
- ⏱️ Response times
- 📊 Test results summary

**Example Output:**
```
✓ Register User (45ms)
✓ Login (32ms)
✓ Get Current User (28ms)
✓ List All Users (67ms)
✗ Delete User (401 Unauthorized)
```

**CI/CD Integration:**
- Export collection as JSON
- Run with Newman CLI
- Integrate with Jenkins/GitHub Actions

---

## Slide 18: Common API Testing Scenarios

### What to Test?

**1. Happy Path**
- ✅ Valid request → Success response
- Example: Register with valid data

**2. Error Handling**
- ✅ Invalid input → Error response
- Example: Register with existing username

**3. Authentication**
- ✅ Missing token → 401
- ✅ Invalid token → 401
- ✅ Valid token → Success

**4. Data Validation**
- ✅ Required fields missing → 400
- ✅ Invalid data types → 400
- ✅ Boundary values

**5. Edge Cases**
- ✅ Empty strings
- ✅ Very long strings
- ✅ Special characters
- ✅ SQL injection attempts

---

## Slide 19: Training App: Complete Test Flow

### End-to-End API Testing

**Step 1: Register**
```http
POST /api/register
{"username": "testuser", "password": "12345"}
→ Save token
```

**Step 2: Login**
```http
POST /api/login
{"username": "testuser", "password": "12345"}
→ Verify token received
```

**Step 3: Get Profile**
```http
GET /api/me
Authorization: Bearer {{token}}
→ Verify username matches
```

**Step 4: List Users**
```http
GET /api/users
Authorization: Bearer {{token}}
→ Verify user appears in list
```

**Step 5: Change Password**
```http
PUT /api/me/password
{"current_password": "12345", "new_password": "newpass"}
→ Verify success
```

**Step 6: Delete Account**
```http
DELETE /api/me
Authorization: Bearer {{token}}
→ Verify deletion
```

---

## Slide 20: API Testing Best Practices

### Do's ✅

1. **Use Environment Variables**
   - Base URLs, tokens, credentials
   - Easy to switch between environments

2. **Write Assertions**
   - Status codes
   - Response structure
   - Data validation

3. **Organize Collections**
   - Group related requests
   - Use folders and naming conventions

4. **Document Requests**
   - Add descriptions
   - Include examples
   - Note expected responses

5. **Test Error Cases**
   - Invalid inputs
   - Missing authentication
   - Edge cases

### Don'ts ❌

1. Don't hardcode values
2. Don't skip error testing
3. Don't ignore response times
4. Don't test in production
5. Don't forget to clean up test data

---

## Slide 21: Status Codes Reference

### HTTP Status Codes

| Code | Meaning | Training App Examples |
|------|---------|---------------------|
| **200** | OK | Login success, Get user |
| **201** | Created | User registered |
| **400** | Bad Request | Invalid password format |
| **401** | Unauthorized | Missing/invalid token |
| **404** | Not Found | User doesn't exist |
| **409** | Conflict | Username already exists |

**Testing Status Codes:**
```javascript
pm.test("Created successfully", function () {
    pm.response.to.have.status(201);
});

pm.test("Unauthorized access", function () {
    pm.response.to.have.status(401);
});
```

---

## Slide 22: Postman vs cURL

### Comparison

**Postman:**
- ✅ Visual interface
- ✅ Easy to use
- ✅ Save and organize
- ✅ Automated testing
- ✅ Team collaboration

**cURL:**
- ✅ Command-line tool
- ✅ Script-friendly
- ✅ Available everywhere
- ✅ Lightweight
- ✅ CI/CD integration

### Example: Same Request

**Postman:**
```
POST http://localhost:8080/api/register
Body: {"username": "test", "password": "12345"}
```

**cURL:**
```bash
curl -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"12345"}'
```

**Both are valid!** Choose based on your needs.

---

## Slide 23: API Testing with Training App

### Hands-On Exercise

**Setup:**
1. Start Training App: `docker compose up -d`
2. Open Postman
3. Create new collection: "Training App Tests"
4. Create environment: "Local"

**Tasks:**
1. ✅ Register a new user
2. ✅ Login and save token
3. ✅ Get current user profile
4. ✅ List all users
5. ✅ Change password
6. ✅ Delete account

**Bonus:**
- Write test assertions
- Create collection runner
- Export collection

---

## Slide 24: Advanced Postman Features

### Power Features

**1. Pre-request Scripts**
```javascript
// Generate random username
const randomUsername = "user_" + Math.random().toString(36).substr(2, 9);
pm.environment.set("random_username", randomUsername);
```

**2. Collection Variables**
- Set at collection level
- Available to all requests
- Override in environments

**3. Mock Servers**
- Create fake API responses
- Test without backend
- Share with frontend team

**4. Documentation**
- Auto-generate from requests
- Add descriptions
- Share with team

**5. Newman CLI**
```bash
newman run collection.json -e environment.json
```

---

## Slide 25: Summary

### Key Takeaways

**API Testing:**
- Tests the backend logic directly
- Faster than UI testing
- Essential for integration

**Tools:**
- Postman: Best for manual testing
- cURL: Best for automation
- Both have their place

**Training App:**
- REST API with JWT authentication
- Perfect for learning API testing
- Real-world examples

**Next Steps:**
1. Practice with Training App
2. Create your own collections
3. Write test assertions
4. Integrate with CI/CD

---

## Slide 26: Resources & Practice

### Learning Resources

**Documentation:**
- Postman Learning Center
- REST API Tutorial
- HTTP Status Codes

**Training App:**
- Base URL: `http://localhost:8080/api`
- Swagger UI: `http://localhost:8080/api/api-docs`
- API Docs: See `API.md`

**Practice Endpoints:**
- `/register` - Create account
- `/login` - Authenticate
- `/me` - Get profile
- `/users` - List users
- `/me/password` - Change password
- `/users/{username}` - Delete user

**Try It Now!**
1. Start the app
2. Open Postman
3. Test the endpoints
4. Write assertions

---

## Slide 27: Q&A

### Questions?

**Common Questions:**

**Q: Why test APIs instead of UI?**
A: Faster, more reliable, catches bugs earlier

**Q: Can I automate API tests?**
A: Yes! Use Postman collections with Newman or Robot Framework

**Q: How do I handle authentication?**
A: Use environment variables to store tokens

**Q: What about testing in CI/CD?**
A: Use Newman CLI or Robot Framework in Jenkins

**Q: How do I test error cases?**
A: Send invalid data and verify error responses

---

## Slide 28: Thank You!

### Happy Testing! 🚀

**Contact:**
- Training App Repository
- API Documentation: `API.md`
- Swagger UI: `http://localhost:8080/api/api-docs`

**Remember:**
- ✅ Test happy paths
- ✅ Test error cases
- ✅ Use environment variables
- ✅ Write assertions
- ✅ Organize collections

**Practice makes perfect!**

---

## Appendix: Quick Reference

### Training App API Endpoints

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/register` | No | Create account |
| POST | `/api/login` | No | Authenticate |
| GET | `/api/me` | Yes | Get profile |
| GET | `/api/users` | Yes | List users |
| PUT | `/api/me/password` | Yes | Change password |
| DELETE | `/api/users/{username}` | Yes | Delete user |
| DELETE | `/api/me` | Yes | Delete own account |

### Postman Tips
- Use `{{variable}}` for variables
- Save tokens automatically
- Write tests in Tests tab
- Organize with collections
- Use environments for different configs
