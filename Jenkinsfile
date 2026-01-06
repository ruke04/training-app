pipeline {
    agent any
    
    parameters {
        // Branch selection - use choice dropdown or custom branch name
        choice(
            name: 'BRANCH',
            choices: ['Master'],
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
        
        stage('Start Services') {
            steps {
                echo 'Building and starting services...'
                sh '''
                    # Get the host path for volume mounts (Jenkins runs in Docker)
                    JENKINS_HOST_PATH=$(docker inspect jenkins --format '{{range .Mounts}}{{if eq .Destination "/var/jenkins_home"}}{{.Source}}{{end}}{{end}}')
                    JOB_DIR=$(echo "$JOB_NAME" | tr '/' '_')
                    HOST_WORKSPACE="${JENKINS_HOST_PATH}/workspace/${JOB_DIR}"
                    
                    # Set the protected site path for docker-compose
                    export PROTECTED_SITE_PATH="${HOST_WORKSPACE}/frontend/hidden-site"
                    echo "Protected site path: $PROTECTED_SITE_PATH"
                    
                    docker compose up -d --build
                    
                    echo "Waiting for services to be healthy..."
                    
                    # Wait for DB to be healthy
                    echo "Checking database..."
                    for i in $(seq 1 30); do
                        if docker compose exec -T db pg_isready -U app -d training > /dev/null 2>&1; then
                            echo "✅ Database is ready"
                            break
                        fi
                        [ $i -eq 30 ] && echo "❌ Database not ready" && exit 1
                        sleep 2
                    done
                    
                    # Wait for Backend API to be healthy (check inside container)
                    echo "Checking backend..."
                    for i in $(seq 1 30); do
                        if docker compose exec -T backend python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api-docs')" > /dev/null 2>&1; then
                            echo "✅ Backend is ready"
                            break
                        fi
                        [ $i -eq 30 ] && echo "❌ Backend not ready" && exit 1
                        sleep 2
                    done
                    
                    # Wait for Frontend (nginx) to be healthy (check inside container)
                    echo "Checking frontend..."
                    for i in $(seq 1 30); do
                        if docker compose exec -T frontend wget -q --spider http://localhost:80 > /dev/null 2>&1; then
                            echo "✅ Frontend is ready"
                            break
                        fi
                        [ $i -eq 30 ] && echo "❌ Frontend not ready" && exit 1
                        sleep 2
                    done
                    
                    echo ""
                    echo "All services are healthy!"
                    docker compose ps
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
