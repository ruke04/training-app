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
                sh 'docker compose build --no-cache'
            }
        }
        
        stage('Start Services') {
            steps {
                echo 'Starting services...'
                sh '''
                    docker compose up -d
                    sleep 10
                    docker compose ps
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Checking service health...'
                sh '''
                    # Use Docker gateway IP (default for Docker Desktop)
                    HOST="172.17.0.1"
                    
                    echo "Using host: $HOST"
                    
                    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
                        if curl -sf --connect-timeout 5 http://$HOST:8000/api-docs >/dev/null 2>&1; then
                            echo "Backend is ready!"
                            break
                        fi
                        echo "Waiting for backend on $HOST:8000... ($i/30)"
                        sleep 2
                    done
                    
                    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
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
                    HOST="172.17.0.1"
                    
                    REGISTER_RESPONSE=$(curl -s -w "\\n%{http_code}" -X POST http://$HOST:8000/register \
                        -H "Content-Type: application/json" \
                        -d '{"username":"jenkins-test","password":"test123"}')
                    
                    CODE=$(echo "$REGISTER_RESPONSE" | tail -n1)
                    echo "Registration response code: $CODE"
                    
                    if [ "$CODE" != "201" ] && [ "$CODE" != "409" ]; then
                        echo "Registration failed with code: $CODE"
                        exit 1
                    fi
                    
                    if [ "$CODE" = "201" ]; then
                        # Extract token using sed (no jq needed)
                        TOKEN=$(echo "$REGISTER_RESPONSE" | head -n1 | sed 's/.*"token":"\\([^"]*\\)".*/\\1/')
                        echo "Testing /me endpoint with token..."
                        curl -f http://$HOST:8000/me -H "Authorization: Bearer $TOKEN" || exit 1
                    else
                        echo "User already exists (409), skipping token test"
                    fi
                    
                    echo "API tests passed!"
                '''
            }
        }
        
        stage('Robot Framework Tests') {
            steps {
                echo 'Running Robot Framework tests...'
                sh 'mkdir -p robot-results'
                sh """
                    HOST="172.17.0.1"
                    
                    echo "Running Robot tests against http://\$HOST:8080"
                    echo "Workspace: ${WORKSPACE}"
                    ls -la ${WORKSPACE}/robot-tests/ || echo "robot-tests folder not found!"
                    ls -la ${WORKSPACE}/robot-tests/test/ || echo "robot-tests/test folder not found!"
                    
                    # Run Robot Framework tests in Docker container
                    docker run --rm \\
                        --network host \\
                        -v "${WORKSPACE}/robot-tests:/robot" \\
                        -v "${WORKSPACE}/robot-results:/results" \\
                        --add-host=host.docker.internal:host-gateway \\
                        marketsquare/robotframework-browser:latest \\
                        bash -c "
                            rfbrowser init chromium && \\
                            robot \\
                                --variable HEADLESS:true \\
                                --variable FRONTEND_URL:http://\$HOST:8080 \\
                                --outputdir /results \\
                                --loglevel DEBUG \\
                                /robot-tests
                        "
                """
            }
            post {
                always {
                    // Archive Robot Framework results
                    archiveArtifacts artifacts: 'robot-results/**/*', allowEmptyArchive: true
                    
                    // Publish Robot Framework results (requires Robot Framework plugin)
                    script {
                        try {
                            step([
                                $class: 'RobotPublisher',
                                outputPath: 'robot-results',
                                outputFileName: 'output.xml',
                                reportFileName: 'report.html',
                                logFileName: 'log.html',
                                passThreshold: 80.0,
                                unstableThreshold: 60.0
                            ])
                        } catch (Exception e) {
                            echo "Robot Framework plugin not installed, skipping result publishing"
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed. Services are still running.'
        }
        success { echo 'Pipeline succeeded! ✅' }
        failure { echo 'Pipeline failed! ❌' }
        unstable { echo 'Pipeline unstable ⚠️' }
    }
}
