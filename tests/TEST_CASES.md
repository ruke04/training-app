# Training App - Test Cases for Automation

## Application Overview
- **Frontend URL:** http://localhost:8080/
- **Backend API URL:** http://localhost:8000/
- **API Documentation:** http://localhost:8000/api-docs

---

## Test Suite 1: User Registration --- Uyi

### TC-REG-001: Successful User Registration
**Priority:** High  
**Type:** Positive  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter a unique username in the "Create Account" username field (e.g., "testuser123")
3. Enter a valid password (min 5 characters) in the password field
4. Click the "Sign Up" button
5. Verify the user was registered successfully

**Expected Results:**
- Success message appears: "Registration successful! Please login to continue."
- Message is displayed in green color
- Username and password fields are cleared
- User is NOT automatically logged in

### TC-REG-002: Registration with Existing Username
**Priority:** High  
**Type:** Negative  
**Precondition:** User "existinguser" already exists  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter "existinguser" in the username field
3. Enter a valid password
4. Click "Sign Up"

**Expected Results:**
- Error message: "Registration failed: Username already exists"
- Message is displayed in red color

### TC-REG-003: Registration with Short Username
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter "ab" (2 characters) in the username field
3. Enter a valid password
4. Click "Sign Up"

**Expected Results:**
- Registration fails with validation error (username min 3 characters)

### TC-REG-004: Registration with Short Password
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter a valid username
3. Enter "1234" (4 characters) in the password field
4. Click "Sign Up"

**Expected Results:**
- Registration fails with validation error (password min 5 characters)

### TC-REG-005: Registration with Empty Fields
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/
2. Leave username field empty
3. Leave password field empty
4. Click "Sign Up"

**Expected Results:**
- Registration fails with validation error

---

## Test Suite 2: User Login   --- Blessing

### TC-LOG-001: Successful Login
**Priority:** High  
**Type:** Positive  
**Precondition:** User "testuser" with password "testpass123" exists  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter "testuser" in the Login username field
3. Enter "testpass123" in the password field
4. Click "Login" button

**Expected Results:**
- Message "Login successful" appears
- Profile section shows logged-in state
- Profile displays username with 👤 icon
- Status shows "Logged in" in green
- Profile JSON data is displayed in the pre element

### TC-LOG-002: Login with Invalid Password
**Priority:** High  
**Type:** Negative  
**Precondition:** User "testuser" exists with different password  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter "testuser" in the username field
3. Enter "wrongpassword" in the password field
4. Click "Login"

**Expected Results:**
- Message "Login failed" appears
- User remains logged out

### TC-LOG-003: Login with Non-Existent User
**Priority:** High  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/
2. Enter "nonexistentuser999" in the username field
3. Enter any password
4. Click "Login"

**Expected Results:**
- Message "Login failed" appears

### TC-LOG-004: Login with Empty Fields
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/
2. Leave username field empty
3. Leave password field empty
4. Click "Login"

**Expected Results:**
- Login fails

### TC-LOG-005: Session Persistence After Page Refresh
**Priority:** Medium  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Refresh the page (F5)

**Expected Results:**
- User remains logged in
- Profile information is automatically fetched and displayed

---

## Test Suite 3: Profile Management     ---- Usifo

### TC-PRO-001: View Profile While Logged In
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Click "Refresh Profile" button

**Expected Results:**
- Profile section displays username
- Status shows "Logged in"
- JSON data shows username in pre element

### TC-PRO-002: View Profile While Logged Out
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/ (not logged in)
2. Click "Refresh Profile" button

**Expected Results:**
- Profile section shows "Not logged in" status
- Pre element shows "Not logged in"

### TC-PRO-003: Profile Display Updates After Login
**Priority:** Medium  
**Type:** Positive  
**Steps:**
1. Navigate to http://localhost:8080/
2. Verify profile shows logged out state
3. Login with valid credentials

**Expected Results:**
- Profile automatically updates to show logged-in state
- Username is displayed with icon
- Status changes to "Logged in" (green)

---

## Test Suite 4: Logout         --- Emmanuel

### TC-OUT-001: Successful Logout
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Verify logged-in state
3. Click "Logout" button

**Expected Results:**
- Notification appears: "Logged out successfully" (green/success)
- Profile section resets to logged-out state
- Token is cleared from localStorage

### TC-OUT-002: Actions After Logout Require Login
**Priority:** Medium  
**Type:** Positive  
**Precondition:** User was logged in, then logged out  
**Steps:**
1. Login, then logout
2. Click "Refresh Profile"

**Expected Results:**
- Profile shows "Not logged in"
- Protected actions show appropriate error messages

---

## Test Suite 5: User Management - List Users   -- Martha

### TC-USR-001: List Users While Logged In
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in, multiple users exist  
**Steps:**
1. Login with valid credentials
2. Click "Show All Users" button

**Expected Results:**
- Users list table appears with columns: ID, Username, Created
- All users in the system are displayed
- Table is scrollable if many users

### TC-USR-002: List Users While Logged Out
**Priority:** High  
**Type:** Negative  
**Steps:**
1. Navigate to http://localhost:8080/ (not logged in)
2. Click "Show All Users" button

**Expected Results:**
- Error notification: "You are not logged in."

### TC-USR-003: Users List Shows Newly Registered User
**Priority:** Medium  
**Type:** Positive  
**Steps:**
1. Login as existing user
2. Click "Show All Users" and note count
3. Open new browser/incognito and register new user
4. Return to first session, click "Show All Users" again

**Expected Results:**
- New user appears in the list

---

## Test Suite 6: Delete User (Admin Function)

### TC-DEL-001: Delete User - Modal Appears
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Enter a username in the "Enter username to delete" field
3. Click "Delete User" button

**Expected Results:**
- Confirmation modal appears
- Modal title: "Delete User"
- Modal message: 'Are you sure you want to delete user "username"? This action cannot be undone.'
- Two buttons visible: "Cancel" and "Confirm"

### TC-DEL-002: Delete User - Cancel Action
**Priority:** High  
**Type:** Positive  
**Steps:**
1. Login with valid credentials
2. Enter a username to delete
3. Click "Delete User" button
4. Click "Cancel" in the modal

**Expected Results:**
- Modal closes
- User is NOT deleted
- No notification appears

### TC-DEL-003: Delete User - Confirm Action
**Priority:** High  
**Type:** Positive  
**Precondition:** User "usertodelete" exists  
**Steps:**
1. Login with valid credentials
2. Enter "usertodelete" in the delete field
3. Click "Delete User" button
4. Click "Confirm" in the modal

**Expected Results:**
- Modal closes
- Success notification: "User 'usertodelete' deleted successfully"
- User is removed from the database
- If users list was shown, it refreshes automatically

### TC-DEL-004: Delete User - Click Outside Modal
**Priority:** Medium  
**Type:** Positive  
**Steps:**
1. Login with valid credentials
2. Enter a username to delete
3. Click "Delete User" button
4. Click outside the modal (on the overlay)

**Expected Results:**
- Modal closes
- User is NOT deleted

### TC-DEL-005: Delete Non-Existent User
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Login with valid credentials
2. Enter "nonexistentuser999" in the delete field
3. Click "Delete User" button
4. Click "Confirm"

**Expected Results:**
- Error notification: "Failed to delete user: User 'nonexistentuser999' not found"

### TC-DEL-006: Delete User Without Entering Username
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Login with valid credentials
2. Leave the delete username field empty
3. Click "Delete User" button

**Expected Results:**
- Error notification: "Please enter a username to delete."
- Modal does NOT appear

### TC-DEL-007: Delete User While Logged Out
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to app (not logged in)
2. Enter a username in the delete field
3. Click "Delete User" button

**Expected Results:**
- Error notification: "You are not logged in."

---

## Test Suite 7: Delete My Account

### TC-ACC-001: Delete Account - Modal Appears
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Click "Delete My Account" button

**Expected Results:**
- Confirmation modal appears
- Modal title: "Delete My Account"
- Modal message: "Are you sure you want to delete your account? This action cannot be undone."

### TC-ACC-002: Delete Account - Cancel Action
**Priority:** High  
**Type:** Positive  
**Steps:**
1. Login with valid credentials
2. Click "Delete My Account" button
3. Click "Cancel"

**Expected Results:**
- Modal closes
- Account is NOT deleted
- User remains logged in

### TC-ACC-003: Delete Account - Confirm Action
**Priority:** High  
**Type:** Positive  
**Steps:**
1. Register a new user "tempuser"
2. Login as "tempuser"
3. Click "Delete My Account"
4. Click "Confirm"

**Expected Results:**
- Modal closes
- Success notification: "Account deleted successfully"
- User is logged out
- Profile section resets
- Attempting to login with "tempuser" fails (user no longer exists)

### TC-ACC-004: Delete Account While Logged Out
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate to app (not logged in)
2. Click "Delete My Account" button

**Expected Results:**
- Error notification: "You are not logged in."

---

## Test Suite 8: Protected Site Access

### TC-PRT-001: Access Protected Site While Logged In
**Priority:** High  
**Type:** Positive  
**Precondition:** User is logged in  
**Steps:**
1. Login with valid credentials
2. Click "Open Protected Site" button

**Expected Results:**
- Browser navigates to protected site (http://localhost:8000/protected?token=...)
- Protected site content is displayed

### TC-PRT-002: Access Protected Site While Logged Out
**Priority:** High  
**Type:** Negative  
**Steps:**
1. Navigate to app (not logged in)
2. Click "Open Protected Site" button

**Expected Results:**
- Error notification: "You are not logged in. Please login first."
- User is NOT redirected

### TC-PRT-003: Direct Access to Protected Site Without Token
**Priority:** Medium  
**Type:** Negative  
**Steps:**
1. Navigate directly to http://localhost:8000/protected (no token)

**Expected Results:**
- HTTP 401 Unauthorized response
- Error: "Missing token"

---

## Test Suite 9: Notifications

### TC-NOT-001: Error Notification Styling
**Priority:** Low  
**Type:** UI Verification  
**Steps:**
1. Trigger an error (e.g., login with wrong password)

**Expected Results:**
- Notification appears in top-right corner
- Red border color
- Auto-dismisses after 3 seconds

### TC-NOT-002: Success Notification Styling
**Priority:** Low  
**Type:** UI Verification  
**Steps:**
1. Trigger a success (e.g., successful logout)

**Expected Results:**
- Notification appears in top-right corner
- Green border color
- Auto-dismisses after 3 seconds

### TC-NOT-003: Notification Manual Dismiss
**Priority:** Low  
**Type:** UI Verification  
**Steps:**
1. Trigger any notification
2. Click on the notification

**Expected Results:**
- Notification dismisses immediately

---

## Test Suite 10: API Direct Testing

### TC-API-001: Register via API
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl -X POST http://localhost:8000/register \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "apipass123"}'
```

**Expected Results:**
- HTTP 201 Created
- Response: `{"token": "<jwt_token>"}`

### TC-API-002: Login via API
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "apiuser", "password": "apipass123"}'
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"token": "<jwt_token>"}`

### TC-API-003: Get Profile via Bearer Token
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl http://localhost:8000/me \
  -H "Authorization: Bearer <jwt_token>"
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"username": "apiuser"}`

### TC-API-004: Get Profile via Basic Auth
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl http://localhost:8000/me \
  -u "apiuser:apipass123"
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"username": "apiuser"}`

### TC-API-005: List Users via API
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl http://localhost:8000/users \
  -H "Authorization: Bearer <jwt_token>"
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"users": [{"id": 1, "username": "...", "created_at": "..."}]}`

### TC-API-006: Delete User via API
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl -X DELETE http://localhost:8000/users/usertodelete \
  -H "Authorization: Bearer <jwt_token>"
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"message": "User 'usertodelete' deleted successfully"}`

### TC-API-007: Delete My Account via API
**Priority:** Medium  
**Type:** API  
**Steps:**
```bash
curl -X DELETE http://localhost:8000/me \
  -H "Authorization: Bearer <jwt_token>"
```

**Expected Results:**
- HTTP 200 OK
- Response: `{"message": "User 'username' deleted successfully"}`

---

## Test Suite 11: End-to-End Workflows

### TC-E2E-001: Complete User Lifecycle
**Priority:** High  
**Type:** E2E  
**Steps:**
1. Register new user "e2euser" with password "e2epass123"
2. Login as "e2euser"
3. Verify profile shows correct username
4. View users list, verify "e2euser" appears
5. Logout
6. Login again
7. Delete account
8. Verify cannot login anymore

**Expected Results:**
- All steps complete successfully
- Final login attempt fails

### TC-E2E-002: Multi-User Interaction
**Priority:** Medium  
**Type:** E2E  
**Steps:**
1. Register user "admin1"
2. Register user "user2" (in different session)
3. Login as "admin1"
4. View users list, see both users
5. Delete "user2"
6. View users list, only "admin1" remains
7. Try to login as "user2" (fails)

**Expected Results:**
- Admin can delete other users
- Deleted user cannot login

---

## Test Data Requirements

| Username | Password | Purpose |
|----------|----------|---------|
| testuser | testpass123 | General testing |
| existinguser | existing123 | Duplicate registration tests |
| adminuser | adminpass123 | User management tests |
| tempuser | temppass123 | Delete account tests |
| apiuser | apipass123 | API testing |

---

## Element Locators (for automation)

| Element | Locator Strategy | Value |
|---------|------------------|-------|
| Reg Username | ID | `reg_username` |
| Reg Password | ID | `reg_password` |
| Sign Up Button | XPath/Text | `//button[text()='Sign Up']` |
| Reg Result | ID | `register_result` |
| Login Username | ID | `username` |
| Login Password | ID | `password` |
| Login Button | XPath/Text | `//button[text()='Login']` |
| Login Result | ID | `result` |
| Profile Display | ID | `profile_display` |
| Profile Username | ID | `profile_username` |
| Profile Status | ID | `profile_status` |
| Refresh Profile | XPath/Text | `//button[text()='Refresh Profile']` |
| Open Protected | XPath/Text | `//button[text()='Open Protected Site']` |
| Logout Button | XPath/Text | `//button[text()='Logout']` |
| Delete My Account | XPath/Text | `//button[text()='Delete My Account']` |
| Show All Users | XPath/Text | `//button[text()='Show All Users']` |
| Users List | ID | `users_list` |
| Delete Username Input | ID | `delete_username` |
| Delete User Button | XPath/Text | `//button[text()='Delete User']` |
| Notification | ID | `notification` |
| Confirm Modal | ID | `confirmModal` |
| Modal Title | ID | `modalTitle` |
| Modal Message | ID | `modalMessage` |
| Modal Cancel | XPath/Class | `.modal-btn-cancel` |
| Modal Confirm | XPath/Class | `.modal-btn-confirm` |
| Profile JSON | ID | `me` |

---

## Notes for Test Automation

1. **Test Isolation:** Each test should clean up created users to maintain isolation
2. **Dynamic Usernames:** Use timestamps or UUIDs to generate unique usernames
3. **Wait Strategies:** Use explicit waits for:
   - Notification appearance/disappearance
   - Modal animations
   - Profile updates after login
4. **State Management:** Token is stored in localStorage - can be manipulated for setup
5. **API + UI:** Consider hybrid approach - use API for setup, UI for verification

