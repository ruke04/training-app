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
                    
                    # Wait for frontend (nginx) which proxies to backend
                    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
                        if curl -sf --connect-timeout 5 http://$HOST:8080 >/dev/null 2>&1; then
                            echo "Frontend is ready!"
                            break
                        fi
                        echo "Waiting for frontend on $HOST:8080... ($i/30)"
                        sleep 2
                    done
                    
                    # Wait for API via nginx proxy
                    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
                        if curl -sf --connect-timeout 5 http://$HOST:8080/api/api-docs >/dev/null 2>&1; then
                            echo "Backend API is ready!"
                            break
                        fi
                        echo "Waiting for backend API on $HOST:8080/api... ($i/30)"
                        sleep 2
                    done
                    
                    echo "Testing final connectivity..."
                    curl -i http://$HOST:8080 || exit 1
                    curl -i http://$HOST:8080/api/api-docs || exit 1
                '''
            }
        }

        stage('Robot Framework Tests') {
            steps {
                echo 'Running Robot Framework tests...'
                sh '''
                    # Get the host path where jenkins-data is mounted by inspecting the Jenkins container
                    JENKINS_HOST_PATH=$(docker inspect jenkins --format '{{range .Mounts}}{{if eq .Destination "/var/jenkins_home"}}{{.Source}}{{end}}{{end}}')
                    # Use JOB_NAME from Jenkins (replace slashes with underscores for folder jobs)
                    JOB_DIR=$(echo "$JOB_NAME" | tr '/' '_')
                    HOST_WORKSPACE="${JENKINS_HOST_PATH}/workspace/${JOB_DIR}"
                    echo "Detected Host Workspace: $HOST_WORKSPACE"
                    echo "Job Name: $JOB_NAME -> Directory: $JOB_DIR"
                    
                    # Create results directory
                    mkdir -p robot-results
                    
                    # Remove old container if exists
                    docker rm -f rf-tests 2>/dev/null || true
                    
                    # Run Robot Framework tests container
                    docker run -d \
                        --name rf-tests \
                        --network host \
                        -v "$HOST_WORKSPACE:/workspace" \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        --add-host=host.docker.internal:host-gateway \
                        marketsquare/robotframework-browser:latest \
                        tail -f /dev/null
                    
                    # Fix permissions and install Docker CLI (static binary - works on any Linux)
                    docker exec --user root rf-tests bash -c "
                        mkdir -p /workspace/robot-results && \
                        chmod 777 /workspace/robot-results && \
                        echo 'Installing Docker CLI (static binary)...' && \
                        curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz | tar xz -C /tmp && \
                        mv /tmp/docker/docker /usr/local/bin/docker && \
                        rm -rf /tmp/docker && \
                        echo 'Installing Docker Compose plugin...' && \
                        mkdir -p /usr/local/lib/docker/cli-plugins && \
                        curl -fsSL https://github.com/docker/compose/releases/download/v2.32.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose && \
                        chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
                        chmod 666 /var/run/docker.sock && \
                        echo 'Docker version:' && docker --version && \
                        echo 'Docker Compose version:' && docker compose version
                    "
                    
                    # Run tests (exit code reflects test results)
                    docker exec rf-tests bash -c "
                        echo 'Installing additional libraries...' && \
                        pip install robotframework-requests && \
                        echo 'Initializing Browser library...' && \
                        rfbrowser init chromium && \
                        echo 'Running Robot Framework tests...' && \
                        robot \
                            --variable HEADLESS:true \
                            --variable FRONTEND_URL:http://localhost:8080 \
                            --variable PROJECT_ROOT:/workspace \
                            --outputdir /workspace/robot-results \
                            /workspace/robot-tests/test && \
                        echo 'Copying any browser screenshots...' && \
                        cp -r /workspace/robot-results/browser/screenshot/* /workspace/robot-results/ 2>/dev/null || true
                    "
                '''
            }
            post {
                always {
                    // Publish Robot Framework results
                    script {
                        try {
                            robot(
                                outputPath: 'robot-results',
                                outputFileName: 'output.xml',
                                logFileName: 'log.html',
                                reportFileName: 'report.html',
                                passThreshold: 100.0,
                                unstableThreshold: 80.0,
                                otherFiles: '**/*.png,**/*.jpg,**/*.jpeg,browser/**/*'
                            )
                        } catch (Exception e) {
                            echo "Robot Framework plugin not installed or no results found: ${e.message}"
                            archiveArtifacts artifacts: 'robot-results/**/*', allowEmptyArchive: true
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh '''
                # Clean up RF test container
                docker stop rf-tests 2>/dev/null || true

                # Stop application containers (keep them for debugging)
                docker compose stop 2>/dev/null || true
                
                echo 'Cleanup complete.'
            '''
        }
        success { echo 'Pipeline succeeded! ✅' }
        failure { echo 'Pipeline failed! ❌' }
        unstable { echo 'Pipeline unstable ⚠️' }
    }
}
