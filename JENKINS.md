# Jenkins CI/CD Setup Guide

Complete guide for setting up Jenkins to run the Training App CI/CD pipeline with Robot Framework tests.

## Quick Start

```bash
# Start Jenkins (works on macOS and Linux)
./jenkins-local-setup.sh

# Access Jenkins at http://localhost:8081
# Use the admin password shown in the terminal output
```

## What the Pipeline Does

1. **Checkout** - Gets source code from repository
2. **Build Docker Images** - Builds backend and frontend containers
3. **Start Services** - Starts db, backend, and frontend via Docker Compose
4. **Health Check** - Verifies services are accessible
5. **API Tests** - Tests registration and authentication endpoints
6. **Robot Framework Tests** - Runs UI tests in headless browser
7. **Cleanup** - Stops containers after tests complete

## Prerequisites

- **Docker** installed and running
- **Git** for source control
- **8081 port available** for Jenkins

## Setup Script Features

The `jenkins-local-setup.sh` script:

| Feature | macOS | Linux |
|---------|-------|-------|
| Docker volume for persistence | ✅ | ✅ |
| Docker CLI inside Jenkins | ✅ | ✅ |
| Docker Compose plugin | ✅ | ✅ |
| Socket permissions | Auto | Auto |
| OS auto-detection | ✅ | ✅ |

## Required Jenkins Plugins

After first login, install these plugins:

1. **Robot Framework Plugin** - For test result publishing
2. **Docker Pipeline** - For Docker support
3. **HTML Publisher Plugin** - For reports (optional)

Go to: **Manage Jenkins** → **Plugins** → **Available plugins**

## Creating the Pipeline Job

1. Open Jenkins: `http://localhost:8081`
2. Click **New Item**
3. Enter name (e.g., `training-app`)
4. Select **Pipeline**
5. Click **OK**

### Configure Pipeline

In **Pipeline** section:
- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: Your repo URL
- **Branch**: `*/main` or `*/Master`
- **Script Path**: `Jenkinsfile`

Click **Save**, then **Build Now**.

## Pipeline Stages Detail

### Health Check
```groovy
// Waits for frontend and backend to be ready
// Uses Docker gateway IP (172.17.0.1) for container-to-host communication
// Tests via Nginx proxy at port 8080
```

### API Tests
```groovy
// Tests user registration at /api/register
// Tests /me endpoint with JWT token
// Uses Nginx proxy paths
```

### Robot Framework Tests
```groovy
// Runs in marketsquare/robotframework-browser container
// Executes tests from robot-tests/test/
// Publishes results via Robot Framework plugin
// Captures screenshots on failure
```

## Test Results

After each build:

| Location | Content |
|----------|---------|
| **Robot Results** | Test pass/fail with trends |
| **Console Output** | Full execution log |
| **robot-results/** | log.html, report.html, screenshots |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `COMPOSE_PROJECT_NAME` | `training-app` | Docker Compose project name |
| `HEADLESS` | `true` | Run browser headless in CI |
| `FRONTEND_URL` | `http://localhost:8080` | App URL for tests |

## Troubleshooting

### Docker Permission Denied
```bash
# The setup script handles this, but if needed:
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Tests Can't Connect to App
- Check services are running: `docker compose ps`
- Verify health check passed in console output
- Ensure port 8080 is not in use by another service

### Robot Framework Plugin Missing
Results will be archived as artifacts instead. Install the plugin for better visualization.

### Container Network Issues
The pipeline uses `--network host` for the RF test container, allowing direct `localhost` access to the app.

### Workspace Path Issues
The pipeline dynamically detects the Jenkins workspace path using `$JOB_NAME`. If you rename the job, the path updates automatically.

## Manual Operations

### Trigger Build
```bash
# Via Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8081 build training-app

# Or click "Build Now" in web UI
```

### View Logs
```bash
# Docker Compose logs
docker compose logs -f

# Jenkins container logs
docker logs jenkins
```

### Stop Services After Build
The pipeline stops containers in the cleanup phase. To manually stop:
```bash
docker compose down
```

## Pipeline Configuration

### Modify Test Thresholds
In Jenkinsfile:
```groovy
robot(
    passThreshold: 100.0,    // Pipeline fails below this
    unstableThreshold: 80.0  // Pipeline unstable below this
)
```

### Add Deployment Stage
```groovy
stage('Deploy') {
    when { branch 'main' }
    steps {
        sh 'docker compose -f docker-compose.prod.yml up -d'
    }
}
```

### Parallel Tests
```groovy
stage('Tests') {
    parallel {
        stage('API Tests') { steps { /* ... */ } }
        stage('UI Tests') { steps { /* ... */ } }
    }
}
```

## Webhook Integration

For automatic builds on push:

1. In Jenkins job: **Build Triggers** → **GitHub hook trigger**
2. In GitHub: **Settings** → **Webhooks** → Add webhook
   - URL: `http://your-jenkins:8081/github-webhook/`
   - Content type: `application/json`
   - Events: Push

## Stopping Jenkins

```bash
# Stop (keeps data)
docker stop jenkins

# Stop and remove (keeps volume)
docker stop jenkins && docker rm jenkins

# Full cleanup (removes data)
docker stop jenkins && docker rm jenkins && docker volume rm jenkins_home
```

## File Locations

| Path | Description |
|------|-------------|
| `Jenkinsfile` | Pipeline definition |
| `jenkins-local-setup.sh` | Setup script |
| `robot-results/` | Test output (created by pipeline) |
| `jenkins_home` volume | Jenkins persistent data |

## Support

1. Check **Console Output** in Jenkins for errors
2. Review `docker compose logs` for service issues
3. Verify `docker compose ps` shows all services running
4. Check Robot Framework `log.html` for test details
