#!/bin/bash
# Quick script to run Jenkins locally with Docker

set -e

echo "🚀 Setting up Jenkins locally with Docker..."

# Check if Jenkins container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^jenkins$"; then
    echo "⚠️  Jenkins container already exists. Removing it..."
    docker stop jenkins 2>/dev/null || true
    docker rm jenkins 2>/dev/null || true
fi

# Create Jenkins data directory
mkdir -p jenkins-data

# Detect OS for Docker socket access
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - Docker Desktop
    echo "📦 Starting Jenkins container (macOS)..."
    docker run -d \
      --name jenkins \
      -p 8081:8080 \
      -p 50000:50000 \
      -v "$(pwd)/jenkins-data:/var/jenkins_home" \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --add-host=host.docker.internal:host-gateway \
      -e JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=" \
      jenkins/jenkins:lts

    echo "⏳ Installing Docker CLI + Compose plugin inside Jenkins..."
    sleep 5
    docker exec -u root jenkins sh -c "
        apt-get update -qq && \
        apt-get install -y ca-certificates curl gnupg -qq && \
        install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
        chmod a+r /etc/apt/keyrings/docker.gpg && \
        echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \$(. /etc/os-release && echo \$VERSION_CODENAME) stable\" > /etc/apt/sources.list.d/docker.list && \
        apt-get update -qq && \
        apt-get install -y docker-ce-cli docker-compose-plugin -qq && \
        # Add legacy docker-compose command alias
        ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true && \
        chmod +x /usr/local/bin/docker-compose || true && \
        chmod 666 /var/run/docker.sock
    " || echo "⚠️ Docker install may need manual setup"

else
    # Linux host
    echo "📦 Starting Jenkins container (Linux)..."
    DOCKER_GID=$(stat -c %g /var/run/docker.sock || echo "999")

    docker run -d \
      --name jenkins \
      -p 8081:8080 \
      -p 50000:50000 \
      -v "$(pwd)/jenkins-data:/var/jenkins_home" \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(which docker):/usr/bin/docker" \
      --group-add "$DOCKER_GID" \
      --add-host=host.docker.internal:host-gateway \
      -e JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=" \
      jenkins/jenkins:lts
fi

echo "⏳ Waiting for Jenkins to start..."

# Wait for Jenkins to generate initialAdminPassword
for i in {1..40}; do
    if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        break
    fi
    echo "   ...waiting ($i/40)"
    sleep 5
done

echo ""
echo "=========================================="
echo "🔑 Initial Admin Password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "⚠️ Not ready yet"
echo "=========================================="
echo ""
echo "✅ Jenkins is starting!"
echo "🌐 Open: http://localhost:8081"
echo ""
echo "🛑 Stop Jenkins: docker stop jenkins"
echo "🗑️  Remove Jenkins: docker stop jenkins && docker rm jenkins"
