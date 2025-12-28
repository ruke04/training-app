# Training App - Test Automation

This directory contains test documentation. The actual Robot Framework tests are located in `robot-tests/`.

## Project Structure

```
training-app/
├── robot-tests/
│   ├── test/                    # Test suites
│   │   ├── Profile_management.robot
│   │   ├── user_login.robot
│   │   ├── user_management.robot
│   │   └── user_registration.robot
│   ├── keywords/
│   │   └── common.robot         # Shared keywords
│   └── pageobject/
│       └── training_app_page.robot  # Page locators
├── tests/
│   ├── TEST_CASES.md            # Test case documentation
│   └── README.md                # This file
└── Jenkinsfile                  # CI/CD pipeline
```

## Prerequisites

1. **Docker** installed and running
2. **Application running** via Docker Compose:
   ```bash
   docker compose up --build -d
   ```
3. For local test execution: **Robot Framework Browser** library installed

## Running Tests

### Using Docker (Recommended)

Run tests in a container with all dependencies pre-installed:

```bash
docker run --rm \
  --network host \
  -v $(pwd):/workspace \
  marketsquare/robotframework-browser:latest \
  bash -c "rfbrowser init chromium && robot --outputdir /workspace/robot-results /workspace/robot-tests/test"
```

### Using Make

```bash
make test
```

### Local Execution

```bash
# Install dependencies
pip install robotframework robotframework-browser
rfbrowser init

# Run all tests
robot -d robot-tests/test_results robot-tests/test

# Run specific test file
robot -d robot-tests/test_results robot-tests/test/user_login.robot

# Run with headless browser
robot -d robot-tests/test_results --variable HEADLESS:true robot-tests/test
```

## Test Suites

| Suite | Description | Test Count |
|-------|-------------|------------|
| `user_registration.robot` | User registration flows | 2 |
| `user_login.robot` | Login/authentication tests | 5 |
| `Profile_management.robot` | Profile display and logout | 3 |
| `user_management.robot` | User listing and management | 3 |

## Test Configuration

Tests can be configured via command-line variables:

```bash
# Run headless (for CI/CD)
robot --variable HEADLESS:true robot-tests/test

# Use different frontend URL
robot --variable FRONTEND_URL:http://192.168.1.100:8080 robot-tests/test
```

## Jenkins CI/CD

The project includes a Jenkinsfile that:
1. Builds and starts the application
2. Runs Robot Framework tests in a container
3. Publishes test results and screenshots

### Quick Start

```bash
# Start Jenkins locally
./jenkins-local-setup.sh

# Access Jenkins at http://localhost:8081
# Create a Pipeline job pointing to this repository
```

### Required Jenkins Plugins

- Robot Framework Plugin
- HTML Publisher Plugin
- Docker Pipeline

## Test Reports

After running tests, the following files are generated in `robot-tests/test_results/`:

| File | Description |
|------|-------------|
| `output.xml` | Machine-readable test results |
| `log.html` | Detailed execution log with screenshots |
| `report.html` | Summary report |

## Troubleshooting

### Browser Not Opening
```bash
# Ensure Browser library is initialized
rfbrowser init chromium
```

### Tests Timing Out
Increase timeout in test keywords or use:
```bash
robot --variable TIMEOUT:30s robot-tests/test
```

### Connection Refused
Ensure the application is running:
```bash
docker compose ps
curl http://localhost:8080
```

### Tests Fail in Jenkins
1. Check that `HEADLESS:true` is set
2. Verify Docker socket permissions
3. Check container network connectivity

## Writing New Tests

1. Add locators to `robot-tests/pageobject/training_app_page.robot`
2. Add keywords to `robot-tests/keywords/common.robot`
3. Create test cases in `robot-tests/test/`

Example test structure:
```robot
*** Settings ***
Resource    ../keywords/common.robot
Suite Setup    Launch Training App
Suite Teardown    Close Browser

*** Test Cases ***
My New Test
    [Documentation]    Description of test
    Enter Login Username    testuser
    Enter Login Password    password123
    Click Login Button
    Wait For Elements State    text=Login successful    visible
```

## API Testing

The Jenkinsfile also includes API tests using curl:

```bash
# Register user
curl -X POST http://localhost:8080/api/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'

# Login
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```
