#!/bin/bash
# Jenkins setup for macOS and Linux (Cloud Servers)
# Supports Docker Desktop (macOS) and native Docker (Linux)

set -e

echo "🚀 Setting up Jenkins with Docker..."

# Ensure Docker exists
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed. Install Docker first."
    exit 1
fi

# Remove existing Jenkins container if present
if docker ps -a --format '{{.Names}}' | grep -q "^jenkins$"; then
    echo "⚠️  Existing Jenkins container found. Removing..."
    docker stop jenkins 2>/dev/null || true
    docker rm jenkins 2>/dev/null || true
fi

# Create persistent Jenkins volume
echo "📦 Creating Jenkins volume..."
docker volume create jenkins_home >/dev/null 2>&1 || true

# Detect OS and configure accordingly
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - Docker Desktop handles permissions automatically
    echo "🍎 Detected macOS (Docker Desktop)"
    
    docker run -d \
      --name jenkins \
      --restart unless-stopped \
      -p 8081:8080 \
      -p 50000:50000 \
      -v jenkins_home:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $HOME/.aws:/var/jenkins_home/.aws:ro \
      -e JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=" \
      jenkins/jenkins:lts
else
    # Linux - need to add Docker socket group
    echo "🐧 Detected Linux"
    DOCKER_GID=$(stat -c %g /var/run/docker.sock)
    echo "🔐 Using Docker socket group ID: $DOCKER_GID"
    
    docker run -d \
      --name jenkins \
      --restart unless-stopped \
      -p 8081:8080 \
      -p 50000:50000 \
      -v jenkins_home:/var/jenkins_home \
      -v /var/run/docker.sock:/var/run/docker.sock \
      --group-add "$DOCKER_GID" \
      -e JAVA_OPTS="-Dhudson.model.DirectoryBrowserSupport.CSP=" \
      jenkins/jenkins:lts
fi

# Wait for Jenkins to boot
echo "⏳ Waiting for Jenkins to initialize..."
sleep 10

# Install Docker CLI + Compose plugin inside Jenkins
echo "🔧 Installing Docker CLI inside Jenkins container..."
docker exec -u root jenkins bash -c "
    apt-get update && \
    apt-get install -y ca-certificates curl gnupg lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
    echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian \$(lsb_release -cs) stable\" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
"

# Fix Docker socket permissions inside container (needed for both OS)
echo "🔧 Fixing Docker socket permissions..."
docker exec -u root jenkins chmod 666 /var/run/docker.sock 2>/dev/null || true

echo "⏳ Waiting for Jenkins password file..."
for i in {1..40}; do
    if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
        break
    fi
    echo "   ...waiting ($i/40)"
    sleep 5
done

# Print admin password
echo ""
echo "=========================================="
echo "🔑 Jenkins Initial Admin Password:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "⚠️ Not ready yet"
echo "=========================================="
echo ""

echo "✅ Jenkins is running!"
echo "🌐 Open Jenkins: http://localhost:8081"
echo ""
echo "🛑 Stop Jenkins: docker stop jenkins"
echo "▶️ Start Jenkins: docker start jenkins"
echo "🗑️ Remove Jenkins: docker stop jenkins && docker rm jenkins"
