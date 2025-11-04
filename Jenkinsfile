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
                echo 'Building Docker images...'
                sh '''
                    # Try docker compose (plugin) first, fallback to docker-compose
                    if command -v docker-compose &> /dev/null; then
                        docker-compose build --no-cache
                    elif docker compose version &> /dev/null; then
                        docker compose build --no-cache
                    else
                        # Install docker-compose if neither works
                        pip3 install docker-compose --break-system-packages || true
                        docker-compose build --no-cache
                    fi
                '''
            }
        }
        
        stage('Start Services') {
            steps {
                echo 'Starting services with docker-compose...'
                sh '''
                    # Try docker compose (plugin) first, fallback to docker-compose
                    if command -v docker-compose &> /dev/null; then
                        docker-compose up -d
                        sleep 10
                        docker-compose ps
                    elif docker compose version &> /dev/null; then
                        docker compose up -d
                        sleep 10
                        docker compose ps
                    else
                        docker-compose up -d
                        sleep 10
                        docker-compose ps
                    fi
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Checking service health...'
                sh '''
                    # Wait for backend to be ready
                    for i in {1..30}; do
                        if curl -f http://localhost:8000/api-docs > /dev/null 2>&1; then
                            echo "Backend is ready!"
                            break
                        fi
                        echo "Waiting for backend... ($i/30)"
                        sleep 2
                    done
                    
                    # Wait for frontend to be ready
                    for i in {1..30}; do
                        if curl -f http://localhost:8080 > /dev/null 2>&1; then
                            echo "Frontend is ready!"
                            break
                        fi
                        echo "Waiting for frontend... ($i/30)"
                        sleep 2
                    done
                    
                    # Verify services
                    curl -i http://localhost:8000/api-docs || exit 1
                    curl -i http://localhost:8080 || exit 1
                '''
            }
        }
        
        stage('Run Robot Framework Tests') {
            steps {
                echo 'Running Robot Framework tests...'
                sh '''
                    # Install Robot Framework Browser if not already installed
                    pip3 install robotframework-browser --quiet || true
                    
                    # Initialize browser if needed
                    rfbrowser init --skip-browsers || true
                    
                    # Run tests (headless mode)
                    HEADLESS=True robot -d results robot-tests/tests || true
                '''
            }
            post {
                always {
                    // Archive test results
                    robot(
                        outputPath: 'results',
                        logFileName: 'log.html',
                        reportFileName: 'report.html',
                        outputFileName: 'output.xml',
                        passThreshold: 80.0,
                        unstableThreshold: 50.0,
                        onlyCritical: false
                    )
                    
                    // Publish test results
                    publishHTML([
                        allowMissing: false,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'results',
                        reportFiles: 'report.html',
                        reportName: 'Robot Framework Test Report'
                    ])
                }
            }
        }
        
        stage('API Tests') {
            steps {
                echo 'Running API tests...'
                sh '''
                    # Test registration
                    REGISTER_RESPONSE=$(curl -s -w "\\n%{http_code}" -X POST http://localhost:8000/register \
                        -H "Content-Type: application/json" \
                        -d '{"username":"jenkins-test","password":"test123"}')
                    
                    HTTP_CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
                    if [ "$HTTP_CODE" != "201" ] && [ "$HTTP_CODE" != "409" ]; then
                        echo "Registration failed with code: $HTTP_CODE"
                        exit 1
                    fi
                    
                    # Extract token if registration was successful
                    if [ "$HTTP_CODE" == "201" ]; then
                        TOKEN=$(echo "$REGISTER_RESPONSE" | head -n1 | jq -r '.token')
                        echo "Token: ${TOKEN:0:20}..."
                        
                        # Test /me endpoint with JWT
                        ME_RESPONSE=$(curl -s -w "\\n%{http_code}" http://localhost:8000/me \
                            -H "Authorization: Bearer $TOKEN")
                        ME_CODE=$(echo "$ME_RESPONSE" | tail -n1)
                        if [ "$ME_CODE" != "200" ]; then
                            echo "/me endpoint failed with code: $ME_CODE"
                            exit 1
                        fi
                        
                        # Test Basic Auth
                        ME_BASIC=$(curl -s -w "\\n%{http_code}" -u jenkins-test:test123 http://localhost:8000/me)
                        ME_BASIC_CODE=$(echo "$ME_BASIC" | tail -n1)
                        if [ "$ME_BASIC_CODE" != "200" ]; then
                            echo "Basic Auth failed with code: $ME_BASIC_CODE"
                            exit 1
                        fi
                    fi
                    
                    echo "API tests passed!"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh '''
                # Use docker-compose or docker compose
                if command -v docker-compose &> /dev/null; then
                    docker-compose down -v || true
                else
                    docker compose down -v || true
                fi
                docker system prune -f || true
            '''
        }
        success {
            echo 'Pipeline succeeded! ✅'
        }
        failure {
            echo 'Pipeline failed! ❌'
        }
        unstable {
            echo 'Pipeline is unstable! ⚠️'
        }
    }
}

