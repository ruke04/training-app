# Jenkins CI/CD Setup Guide

This guide explains how to set up and use Jenkins for continuous integration and deployment of the Training App.

## Quick Start

Run the setup script to start Jenkins locally:
```bash
./jenkins-local-setup.sh
```

This will:
- Start Jenkins in a Docker container on port **8081**
- Install Docker CLI and docker-compose plugin
- Display the initial admin password
- Configure Docker socket access

## Prerequisites

1. **Docker installed** (Docker Desktop for Mac/Windows, or Docker Engine for Linux)
2. **Git repository** with your code (or use local filesystem)
3. **Required Jenkins plugins** (will be prompted during setup):
   - Docker Pipeline
   - HTML Publisher Plugin (optional)
4. **System requirements:**
   - Docker and Docker Compose installed
   - Jenkins runs in Docker container (port 8081)

## Jenkins Setup

### 1. Install Required Plugins

1. Go to **Manage Jenkins** → **Plugins** → **Available**
2. Search and install:
   - `Docker Pipeline` (for Docker support)
   - `HTML Publisher Plugin` (optional, for HTML reports)
   - `Docker Compose Build Step` (optional)

### 2. Quick Setup with Script

The easiest way to set up Jenkins:

```bash
# Run the setup script
./jenkins-local-setup.sh
```

This script will:
- Start Jenkins on port **8081** (to avoid conflicts with frontend on 8080)
- Install Docker CLI and docker-compose plugin inside Jenkins
- Configure Docker socket access
- Display the admin password

Access Jenkins at: `http://localhost:8081`

### 3. Manual Docker Setup (Alternative)

If you prefer manual setup:

```bash
# Start Jenkins container
docker run -d \
  --name jenkins \
  -p 8081:8080 \
  -p 50000:50000 \
  -v $(pwd)/jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Get admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 4. Create a Jenkins Pipeline Job

1. Open Jenkins: `http://localhost:8081`
2. Enter the admin password (shown by setup script)
3. Complete the setup wizard (install suggested plugins)
4. **New Item** → Select **Pipeline**
5. Configure the pipeline:
   - **Pipeline definition**: Pipeline script from SCM
   - **SCM**: Git (or your version control)
   - **Repository URL**: Your repository URL (e.g., `https://github.com/yourusername/training-app.git`)
   - **Branch Specifier**: `*/main` or `*/Master` (not `*/master`)
   - **Credentials**: If private repo
   - **Script Path**: `Jenkinsfile`
6. Click **Save**

### 5. Alternative: Manual Pipeline Configuration

If you prefer to configure manually:

1. **New Item** → **Pipeline**
2. In **Pipeline** section:
   - Definition: **Pipeline script**
   - Copy the contents of `Jenkinsfile` into the script box

## Pipeline Stages

The Jenkins pipeline includes:

1. **Checkout**: Gets source code from repository
2. **Build Docker Images**: Builds backend and frontend containers with docker-compose
3. **Start Services**: Starts all services (db, backend, frontend) with docker-compose
4. **Health Check**: Verifies services are running and accessible
   - Detects host automatically (uses `host.docker.internal` for Docker Desktop)
   - Checks backend at port 8000
   - Checks frontend at port 8080
5. **API Tests**: Tests API endpoints (registration, login, JWT, Basic Auth)
6. **Post Actions**: Services remain running after build completion

**Note**: Services are not automatically stopped after the build. They remain running for further testing or debugging.

## Test Results

After each run:
- **Console Output**: Detailed logs of all pipeline stages
- **Build Status**: Success ✅, Failure ❌, or Unstable ⚠️
- **Services**: Remain running after build for manual testing

## Accessing Running Services

After a successful build, services are accessible at:
- **Backend API**: `http://localhost:8000`
- **Frontend**: `http://localhost:8080`
- **Swagger UI**: `http://localhost:8000/api-docs`

To stop services manually:
```bash
docker compose down
```

## Manual Jenkins Execution

### Using Jenkins CLI

```bash
# Download Jenkins CLI (if needed)
wget http://localhost:8081/jnlpJars/jenkins-cli.jar

# Trigger a build
java -jar jenkins-cli.jar -s http://localhost:8081 build training-app-pipeline

# Get build status
java -jar jenkins-cli.jar -s http://localhost:8081 get-build training-app-pipeline 1
```

### Using Jenkins Web UI

1. Navigate to your pipeline job
2. Click **Build Now**
3. View progress in **Console Output**
4. Check **Test Results** after completion

## Environment Variables

You can customize the pipeline by setting environment variables:

- `COMPOSE_PROJECT_NAME`: Docker Compose project name (default: `training-app`)
- `HEADLESS`: Set to `true` for headless browser tests (default: `false`)

To set in Jenkins:
1. Go to **Pipeline** configuration
2. Add environment variables in **Pipeline** section → **Environment variables**

## Troubleshooting

### Docker Permission Issues

```bash
# Ensure Jenkins user can run Docker
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock
sudo systemctl restart jenkins
```

### Port Conflicts

- **Jenkins runs on port 8081** (to avoid conflict with frontend on 8080)
- If ports 8000 or 8080 are already in use:
  - Modify `docker-compose.yml` to use different ports
  - Update health check URLs in `Jenkinsfile`

### Host Connectivity Issues

If health checks fail with "Could not connect":
- Jenkins automatically detects host using `host.docker.internal` (Docker Desktop)
- For Linux, it detects the Docker gateway IP
- Check that services are actually running: `docker compose ps`

### Docker Compose Not Found

If you see "docker compose not found" errors:
- The setup script automatically installs docker-compose plugin
- If manual setup, install inside Jenkins container:
  ```bash
  docker exec -u root jenkins sh -c "apt-get update && apt-get install -y docker-compose-plugin"
  ```

### Test Failures

1. Check **Console Output** for detailed errors
2. Verify services are running: `docker compose ps`
3. Check service logs: `docker compose logs backend`
4. Test API manually: `curl http://localhost:8000/api-docs`
5. Check host detection: Look for "Using host: ..." in console output

## Webhooks (GitHub/GitLab Integration)

Set up automatic builds on push:

1. **Pipeline** → **Build Triggers** → **GitHub hook trigger for GITScm polling**
2. Configure webhook in your Git repository:
   - URL: `http://your-jenkins-url:8081/github-webhook/`
   - Content type: `application/json`
   - Events: Push events

## Advanced Configuration

### Parallel Test Execution

Modify `Jenkinsfile` to run tests in parallel:

```groovy
stage('Run Tests') {
    parallel {
        stage('Health Check') {
            steps { /* Health check tests */ }
        }
        stage('API Tests') {
            steps { /* API tests */ }
        }
    }
}
```

### Deployment Stage

Add deployment after successful tests:

```groovy
stage('Deploy') {
    when {
        branch 'main'
    }
    steps {
        sh '''
            # Your deployment commands here
            docker compose -f docker-compose.prod.yml up -d
        '''
    }
}
```

## Example Jenkinsfile Usage

The included `Jenkinsfile` is a complete CI/CD pipeline that:
- ✅ Builds Docker images with docker-compose
- ✅ Starts all services (db, backend, frontend)
- ✅ Runs health checks (auto-detects host connectivity)
- ✅ Tests API endpoints (registration, login, JWT, Basic Auth)
- ✅ Keeps services running after build for testing
- ✅ Supports both docker-compose and docker compose commands

## Key Features

- **Automatic host detection**: Uses `host.docker.internal` for Docker Desktop or detects gateway IP
- **Docker Compose compatibility**: Works with both `docker-compose` and `docker compose`
- **Services persist**: Services remain running after build for manual testing
- **Comprehensive API tests**: Tests registration, JWT auth, and Basic Auth

## Stopping Jenkins

```bash
# Stop Jenkins
docker stop jenkins

# Stop and remove Jenkins (keeps data)
docker stop jenkins && docker rm jenkins

# Remove Jenkins and all data (fresh start)
docker stop jenkins && docker rm jenkins && rm -rf jenkins-data
```

## Support

For issues or questions:
1. Check Jenkins console logs in web UI
2. Review Docker Compose logs: `docker compose logs`
3. Verify services are running: `docker compose ps`
4. Check host connectivity: Look for "Using host: ..." in console
5. Verify docker-compose is installed in Jenkins container

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| "docker compose not found" | Run `./jenkins-local-setup.sh` or install docker-compose-plugin in container |
| "Could not connect" | Check host detection in console output, verify services are running |
| "Port already in use" | Jenkins uses 8081, frontend uses 8080, backend uses 8000 |
| "Branch not found" | Set branch specifier to `*/main` or `*/Master`, not `*/master` |
| Services not accessible | Check docker compose ps, verify ports are exposed |

