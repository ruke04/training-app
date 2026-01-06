pipeline {
    agent any
    
    parameters {
        // Branch selection - use choice dropdown or custom branch name
        choice(
            name: 'BRANCH',
            choices: ['Master', 'main', 'master', 'develop', 'staging'],
            description: 'Select branch to build from common branches'
        )
        string(
            name: 'BRANCH_CUSTOM',
            defaultValue: '',
            description: 'Or enter a custom branch name (leave empty to use BRANCH selection above)'
        )
    }
    
    environment {
        COMPOSE_PROJECT_NAME = 'training-app'
        DOCKER_BUILDKIT = '1'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('List Available Branches') {
            steps {
                script {
                    echo "Fetching available branches from repository..."
                    def repoUrl = scm.userRemoteConfigs[0].url
                    
                    // Fetch all branches from remote repository
                    sh """
                        echo "Repository URL: ${repoUrl}"
                        echo ""
                        echo "Available branches:"
                        git ls-remote --heads ${repoUrl} | sed 's/.*refs\\/heads\\///' | sort || echo "Could not fetch branches (will proceed with checkout)"
                    """
                }
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    // Determine which branch to checkout
                    def selectedBranch = params.BRANCH
                    def customBranch = params.BRANCH_CUSTOM
                    
                    // Validate and set branch (handle null, empty, or "null" string)
                    def branchToCheckout = null
                    
                    // Use custom branch if provided, otherwise use selected branch from dropdown
                    if (customBranch && customBranch.trim() && customBranch != 'null') {
                        branchToCheckout = customBranch.trim()
                        echo "Using custom branch: ${branchToCheckout}"
                    } else if (selectedBranch && selectedBranch.trim() && selectedBranch != 'null') {
                        branchToCheckout = selectedBranch.trim()
                        echo "Using selected branch: ${branchToCheckout}"
                    } else {
                        // Default to main or Master if no valid branch specified
                        echo "WARNING: No valid branch specified. Checking available branches..."
                        def repoUrl = scm.userRemoteConfigs[0].url
                        def branches = sh(
                            script: "git ls-remote --heads ${repoUrl} | sed 's/.*refs\\/heads\\///' | sort",
                            returnStdout: true
                        ).trim().split('\n')
                        
                        // Try main first, then Master, then first available branch
                        if (branches.contains('main')) {
                            branchToCheckout = 'main'
                        } else if (branches.contains('Master')) {
                            branchToCheckout = 'Master'
                        } else if (branches.size() > 0) {
                            branchToCheckout = branches[0]
                        } else {
                            error("No branches found in repository and no branch specified!")
                        }
                        echo "Using default branch: ${branchToCheckout}"
                    }
                    
                    echo "Checking out branch: ${branchToCheckout}"
                    
                    // Get the repository URL from SCM
                    def repoUrl = scm.userRemoteConfigs[0].url
                    def credentialsId = scm.userRemoteConfigs[0].credentialsId
                    
                    // Validate branch exists before checkout
                    def branchExists = sh(
                        script: "git ls-remote --heads ${repoUrl} | grep -q 'refs/heads/${branchToCheckout}' || echo 'NOT_FOUND'",
                        returnStatus: true
                    )
                    
                    if (branchExists != 0) {
                        error("Branch '${branchToCheckout}' does not exist in repository. Please select a valid branch.")
                    }
                    
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: "*/${branchToCheckout}"]],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        userRemoteConfigs: [[
                            url: repoUrl,
                            credentialsId: credentialsId ?: ''
                        ]]
                    ])
                    
                    // Display checked out branch and verify
                    sh """
                        echo "=== Checkout Verification ==="
                        git branch -v
                        echo ""
                        echo "Current commit:"
                        git log -1 --oneline
                        echo ""
                        echo "Branch: \$(git rev-parse --abbrev-ref HEAD)"
                    """
                }
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
                    # Docker Compose will handle dependencies automatically:
                    # 1. Start db and wait for it to be healthy
                    # 2. Start backend (depends on db being healthy)
                    # 3. Start frontend
                    docker compose up -d
                    
                    # Wait for all services to be running
                    echo "Waiting for all services to start..."
                    sleep 10
                    
                    # Check container status
                    echo "=== Container Status ==="
                    docker compose ps
                    echo ""
                    
                    # Verify all containers are running
                    if ! docker compose ps | grep -q "Up.*backend"; then
                        echo "❌ Backend container is not running!"
                        docker compose logs --tail=50 backend
                        exit 1
                    fi
                    
                    if ! docker compose ps | grep -q "Up.*frontend"; then
                        echo "❌ Frontend container is not running!"
                        docker compose logs --tail=50 frontend
                        exit 1
                    fi
                    
                    echo "✅ All containers are running"
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Checking service health...'
                sh '''
                    # Detect host IP for external access
                    if command -v ip >/dev/null 2>&1; then
                        HOST=$(ip route | grep default | awk '{print $3}' | head -1)
                    elif command -v route >/dev/null 2>&1; then
                        HOST=$(route -n get default 2>/dev/null | grep gateway | awk '{print $2}' | head -1)
                    else
                        HOST="172.17.0.1"
                    fi
                    
                    if [ -z "$HOST" ]; then
                        HOST="localhost"
                    fi
                    
                    echo "Using host: $HOST"
                    
                    # Verify backend is responding
                    echo "Checking backend..."
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                        if docker compose exec -T backend python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api-docs').read()" 2>/dev/null; then
                            echo "✅ Backend is responding"
                            break
                        fi
                        if [ $i -eq 10 ]; then
                            echo "❌ Backend health check failed"
                            docker compose logs --tail=30 backend
                            exit 1
                        fi
                        sleep 2
                    done
                    
                    # Verify frontend is accessible
                    echo "Checking frontend..."
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                        if curl -sf --connect-timeout 5 http://$HOST:8080 >/dev/null 2>&1; then
                            echo "✅ Frontend is accessible"
                            break
                        fi
                        if [ $i -eq 10 ]; then
                            echo "❌ Frontend health check failed"
                            docker compose logs --tail=30 frontend
                            exit 1
                        fi
                        sleep 2
                    done
                    
                    # Verify backend API via proxy
                    echo "Checking backend API via proxy..."
                    for i in 1 2 3 4 5 6 7 8 9 10; do
                        if curl -sf --connect-timeout 5 http://$HOST:8080/api/api-docs >/dev/null 2>&1; then
                            echo "✅ Backend API is accessible via proxy"
                            break
                        fi
                        if [ $i -eq 10 ]; then
                            echo "❌ Backend API proxy check failed"
                            echo "Nginx logs:"
                            docker compose logs --tail=30 frontend
                            echo "Backend logs:"
                            docker compose logs --tail=30 backend
                            exit 1
                        fi
                        sleep 2
                    done
                    
                    echo ""
                    echo "✅ All health checks passed"
                '''
            }
        }
        
        stage('Verify Volume Mounts') {
            steps {
                echo 'Verifying backend volume mounts...'
                sh '''
                    # Check if protected site files are accessible in backend container
                    docker compose exec -T backend ls -la /app/protected_site/ || echo "Directory listing failed"
                    docker compose exec -T backend test -f /app/protected_site/index.html && echo "✅ index.html exists" || echo "❌ index.html missing"
                    docker compose exec -T backend env | grep PROTECTED_DIR || echo "PROTECTED_DIR not set"
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
