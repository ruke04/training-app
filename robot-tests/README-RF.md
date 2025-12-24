# Robot Framework Test Suite

UI automation tests for the Training App using Robot Framework Browser library.

## Directory Structure

```
robot-tests/
├── test/                          # Test suites
│   ├── user_registration.robot    # Registration tests
│   ├── user_login.robot           # Login tests
│   ├── user_management.robot      # User listing tests
│   └── profile_management.robot   # Profile & logout tests
├── keywords/
│   └── common.robot               # Shared keywords
├── pageobject/
│   └── training_app_page.robot    # Element locators
├── test_results/                  # Test output (gitignored)
├── Dockerfile                     # RF Browser container
└── README-RF.md                   # This file
```

## Prerequisites

- Application running at `http://localhost:8080`
- Python 3.8+ (for local execution)
- Docker (for containerized execution)

## Running Tests

### Quick Start (Docker - Recommended)

```bash
# Ensure app is running
docker compose up -d

# Run tests in container
docker run --rm --network host \
  -v $(pwd):/workspace \
  marketsquare/robotframework-browser:latest \
  bash -c "rfbrowser init chromium && robot \
    --variable HEADLESS:true \
    --outputdir /workspace/robot-tests/test_results \
    /workspace/robot-tests/test"
```

### Using Makefile

```bash
make test
```

### Local Execution

```bash
# Install dependencies
pip install robotframework robotframework-browser
rfbrowser init chromium

# Run all tests
robot -d robot-tests/test_results robot-tests/test

# Run specific suite
robot -d robot-tests/test_results robot-tests/test/user_login.robot

# Run headless
robot -d robot-tests/test_results --variable HEADLESS:true robot-tests/test
```

## Test Suites

| Suite | Description | Test Count |
|-------|-------------|------------|
| `user_registration.robot` | User signup flows | 2 |
| `user_login.robot` | Login/auth scenarios | 5 |
| `user_management.robot` | User listing & creation | 3 |
| `profile_management.robot` | Profile display & logout | 3 |

**Total: 13 tests**

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HEADLESS` | `false` | Run browser headless |
| `FRONTEND_URL` | `http://localhost:8080` | Application URL |

```bash
# Example: Run against different URL
robot --variable FRONTEND_URL:http://192.168.1.100:8080 robot-tests/test

# Example: Run headless for CI
robot --variable HEADLESS:true robot-tests/test
```

## Page Object Model

Locators are defined in `pageobject/training_app_page.robot`:

```robot
*** Variables ***
${TRAINING_APP_TITLE}     //*[text()="🧪 Training App"]
${LOGIN_USERNAME}         //input[@id="username"]
${LOGIN_PASSWORD}         //input[@id="password"]
${LOGIN_BUTTON}           //button[text()="Login"]
${LOGOUT_BUTTON}          //button[text()='Logout']
# ... more locators
```

## Keywords

Common keywords in `keywords/common.robot`:

| Keyword | Description |
|---------|-------------|
| `Launch Training App` | Opens browser and navigates to app |
| `Enter Login Username` | Types username in login field |
| `Enter Login Password` | Types password in login field |
| `Click Login Button` | Clicks the login button |
| `Click Logout Button` | Clicks the logout button |
| `Enter Username` | Types in registration username field |
| `Enter Password` | Types in registration password field |
| `Click Sign Up Button` | Clicks the sign up button |

## Writing New Tests

### 1. Add Locators (if needed)

```robot
# pageobject/training_app_page.robot
${MY_NEW_ELEMENT}    //button[@id="my-button"]
```

### 2. Add Keywords (if needed)

```robot
# keywords/common.robot
Click My New Button
    Wait For Element To Be Visible    ${MY_NEW_ELEMENT}
    Click    ${MY_NEW_ELEMENT}
```

### 3. Create Test Case

```robot
# test/my_new_test.robot
*** Settings ***
Resource    ../keywords/common.robot
Suite Setup    Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***
My New Feature Test
    [Documentation]    Test the new feature
    Enter Login Username    testuser
    Enter Login Password    password123
    Click Login Button
    Wait For Elements State    text=Login successful    visible
    Click My New Button
    # ... assertions
```

## Test Reports

After execution, find reports in `test_results/`:

| File | Description |
|------|-------------|
| `report.html` | Summary with pass/fail |
| `log.html` | Detailed execution log |
| `output.xml` | Machine-readable results |
| `browser/screenshot/` | Failure screenshots |

## CI/CD Integration

Tests run automatically in Jenkins pipeline:

```groovy
// From Jenkinsfile
docker exec rf-tests bash -c "
    rfbrowser init chromium && \
    robot \
        --variable HEADLESS:true \
        --variable FRONTEND_URL:http://localhost:8080 \
        --outputdir /workspace/robot-results \
        /workspace/robot-tests/test
"
```

## Troubleshooting

### Browser Not Starting
```bash
# Reinitialize browser
rfbrowser init chromium
```

### Element Not Found
1. Check locator in `training_app_page.robot`
2. Verify element exists in browser DevTools
3. Increase timeout: `Wait For Elements State    ${ELEMENT}    visible    timeout=30s`

### Tests Timeout
```bash
# Increase default timeout
robot --variable TIMEOUT:30s robot-tests/test
```

### Connection Refused
```bash
# Verify app is running
docker compose ps
curl http://localhost:8080
```

### Screenshots Not Captured
Browser library auto-captures on failure. Check `test_results/browser/screenshot/`.

## Best Practices

1. **Use Page Objects** - Keep locators in `training_app_page.robot`
2. **Reusable Keywords** - Add common actions to `common.robot`
3. **Explicit Waits** - Use `Wait For Elements State` instead of `Sleep`
4. **Unique Test Data** - Generate random usernames to avoid conflicts
5. **Suite Setup/Teardown** - Open browser once per suite, not per test

## Dependencies

- robotframework >= 6.0
- robotframework-browser >= 17.0
- Python >= 3.8
- Node.js (installed by rfbrowser init)
- Playwright browsers (installed by rfbrowser init)
