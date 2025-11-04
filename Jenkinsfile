pipeline {
    agent any
    
    environment {
        COMPOSE_PROJECT_NAME = 'training-app'
        DOCKER_BUILDKIT = '1'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Build Docker Images') {
            steps {
                echo 'Ensuring docker-compose alias exists...'
                sh '''
                    # If docker compose exists but docker-compose does not, create alias
                    if command -v docker compose >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
                        echo "Creating docker-compose symlink..."
                        sudo ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose 2>/dev/null \
                        || ln -sf /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
                        chmod +x /usr/local/bin/docker-compose || true
                    fi
                '''

                echo 'Building Docker images...'
                sh '''
                    if command -v docker-compose &> /dev/null; then
                        docker-compose build --no-cache
                    elif docker compose version &> /dev/null; then
                        docker compose build --no-cache
                    else
                        echo "❌ No docker compose available"
                        exit 1
                    fi
                '''
            }
        }
        
        stage('Start Services') {
            steps {
                echo 'Starting services...'
                sh '''
                    if command -v docker-compose &> /dev/null; then
                        docker-compose up -d
                        sleep 10
                        docker-compose ps
                    else
                        docker compose up -d
                        sleep 10
                        docker compose ps
                    fi
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Checking service health...'
                sh '''
                    # Detect host - try host.docker.internal first (Docker Desktop)
                    HOST=""
                    if getent hosts host.docker.internal >/dev/null 2>&1; then
                        HOST="host.docker.internal"
                    elif command -v hostname >/dev/null 2>&1 && hostname -I >/dev/null 2>&1; then
                        # Try to get host IP from hostname
                        HOST=$(hostname -I | awk '{print $1}')
                    else
                        # Fallback: use gateway IP from route or default
                        HOST=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}' || \
                               netstat -rn | grep '^default' | awk '{print $2}' | head -1 || \
                               echo "host.docker.internal")
                    fi
                    
                    # Final fallback if still empty
                    if [ -z "$HOST" ] || [ "$HOST" = "" ]; then
                        HOST="host.docker.internal"
                    fi
                    
                    echo "Using host: $HOST"
                    
                    # Test if host is reachable
                    if ! curl -sf --connect-timeout 2 http://$HOST:8000 >/dev/null 2>&1 && \
                       ! curl -sf --connect-timeout 2 http://$HOST:8080 >/dev/null 2>&1; then
                        echo "⚠️  Warning: $HOST may not be reachable, trying alternative..."
                        # Try localhost as last resort (might work if services are on same network)
                        HOST="localhost"
                    fi
                    
                    for i in {1..30}; do
                        if curl -sf --connect-timeout 5 http://$HOST:8000/api-docs >/dev/null 2>&1; then
                            echo "Backend is ready!"
                            break
                        fi
                        echo "Waiting for backend on $HOST:8000... ($i/30)"
                        sleep 2
                    done
                    
                    for i in {1..30}; do
                        if curl -sf --connect-timeout 5 http://$HOST:8080 >/dev/null 2>&1; then
                            echo "Frontend is ready!"
                            break
                        fi
                        echo "Waiting for frontend on $HOST:8080... ($i/30)"
                        sleep 2
                    done
                    
                    echo "Testing final connectivity..."
                    curl -i http://$HOST:8000/api-docs || exit 1
                    curl -i http://$HOST:8080 || exit 1
                '''
            }
        }
        
        stage('API Tests') {
            steps {
                echo 'Running API tests...'
                sh '''
                    # Use same host detection as health check
                    HOST=""
                    if getent hosts host.docker.internal >/dev/null 2>&1; then
                        HOST="host.docker.internal"
                    elif command -v hostname >/dev/null 2>&1 && hostname -I >/dev/null 2>&1; then
                        HOST=$(hostname -I | awk '{print $1}')
                    else
                        HOST=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}' || \
                               netstat -rn | grep '^default' | awk '{print $2}' | head -1 || \
                               echo "host.docker.internal")
                    fi
                    if [ -z "$HOST" ] || [ "$HOST" = "" ]; then
                        HOST="host.docker.internal"
                    fi
                    
                    REGISTER_RESPONSE=$(curl -s -w "\\n%{http_code}" -X POST http://$HOST:8000/register \
                        -H "Content-Type: application/json" \
                        -d '{"username":"jenkins-test","password":"test123"}')
                    
                    CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
                    if [ "$CODE" != "201" ] && [ "$CODE" != "409" ]; then exit 1; fi
                    
                    if [ "$CODE" == "201" ]; then
                        TOKEN=$(echo "$REGISTER_RESPONSE" | head -n1 | jq -r '.token')
                        curl -f http://$HOST:8000/me -H "Authorization: Bearer $TOKEN" || exit 1
                        curl -f -u jenkins-test:test123 http://$HOST:8000/me || exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed. Services are still running.'
            echo 'To stop services manually, run: docker compose down'
        }
        success { echo 'Pipeline succeeded! ✅' }
        failure { echo 'Pipeline failed! ❌' }
        unstable { echo 'Pipeline unstable ⚠️' }
    }
}
