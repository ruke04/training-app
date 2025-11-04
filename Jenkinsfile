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
                    # Use host.docker.internal for Docker Desktop (Mac/Windows) or detect host IP
                    if ping -c 1 host.docker.internal >/dev/null 2>&1; then
                        HOST="host.docker.internal"
                    else
                        # For Linux, get Docker host IP from gateway
                        HOST=$(ip route | grep default | awk '{print $3}' || echo "localhost")
                    fi
                    
                    echo "Using host: $HOST"
                    
                    for i in {1..30}; do
                        if curl -sf http://$HOST:8000/api-docs >/dev/null 2>&1; then
                            echo "Backend is ready!"
                            break
                        fi
                        echo "Waiting for backend... ($i/30)"
                        sleep 2
                    done
                    
                    for i in {1..30}; do
                        if curl -sf http://$HOST:8080 >/dev/null 2>&1; then
                            echo "Frontend is ready!"
                            break
                        fi
                        echo "Waiting for frontend... ($i/30)"
                        sleep 2
                    done
                    
                    curl -i http://$HOST:8000/api-docs || exit 1
                    curl -i http://$HOST:8080 || exit 1
                '''
            }
        }
        
        stage('Run Robot Framework Tests') {
            steps {
                echo 'Running Robot Framework tests...'
                sh '''
                    # Detect host (same as health check)
                    if ping -c 1 host.docker.internal >/dev/null 2>&1; then
                        HOST="host.docker.internal"
                    else
                        HOST=$(ip route | grep default | awk '{print $3}' || echo "localhost")
                    fi
                    
                    echo "Using host for tests: $HOST"
                    
                    # Update Robot test to use correct host
                    sed -i "s|http://localhost:8080|http://$HOST:8080|g" robot-tests/tests/web_login_test.robot || true
                    
                    pip3 install robotframework-browser --quiet || true
                    rfbrowser init --skip-browsers || true
                    HEADLESS=True robot -d results robot-tests/tests || true
                '''
            }
            post {
                always {
                    robot outputPath: 'results'
                    publishHTML([
                        reportDir: 'results',
                        reportFiles: 'report.html',
                        reportName: 'Robot Tests'
                    ])
                }
            }
        }
        
        stage('API Tests') {
            steps {
                echo 'Running API tests...'
                sh '''
                    # Use same host as health check
                    if ping -c 1 host.docker.internal >/dev/null 2>&1; then
                        HOST="host.docker.internal"
                    else
                        HOST=$(ip route | grep default | awk '{print $3}' || echo "localhost")
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
            echo 'Cleaning up...'
            sh '''
                if command -v docker-compose &> /dev/null; then
                    docker-compose down -v || true
                else
                    docker compose down -v || true
                fi
            '''
        }
        success { echo 'Pipeline succeeded! ✅' }
        failure { echo 'Pipeline failed! ❌' }
        unstable { echo 'Pipeline unstable ⚠️' }
    }
}
