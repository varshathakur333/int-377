pipeline {
    agent any

    environment {
        APP_DIR = '/home/ec2-user/app'
        COMPOSE_FILE = "${APP_DIR}/docker-compose.yml"
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Pulling latest code from repository...'
                checkout scm
            }
        }

        stage('Verify Docker') {
            steps {
                echo '🐳 Verifying Docker is available...'
                sh 'docker --version'
                sh 'docker-compose --version'
            }
        }

        stage('Copy Files to App Directory') {
            steps {
                echo '📂 Syncing workspace files to app directory...'
                sh """
                    mkdir -p ${APP_DIR}/grafana/provisioning/datasources
                    mkdir -p ${APP_DIR}/grafana/provisioning/dashboards
                    mkdir -p ${APP_DIR}/grafana/dashboards
                    cp -r ${WORKSPACE}/. ${APP_DIR}/
                """
            }
        }

        stage('Build & Deploy') {
            steps {
                echo '🚀 Building Docker image and deploying stack...'
                sh """
                    cd ${APP_DIR}
                    docker-compose down --remove-orphans || true
                    docker-compose up --build -d
                """
            }
        }

        stage('Health Check') {
            steps {
                echo '🩺 Running health checks on services...'
                sh """
                    sleep 10
                    docker-compose -f ${COMPOSE_FILE} ps
                    curl -f http://localhost:80 && echo '✅ Weather App is UP' || echo '❌ Weather App is DOWN'
                    curl -f http://localhost:9090 && echo '✅ Prometheus is UP' || echo '❌ Prometheus is DOWN'
                    curl -f http://localhost:3000 && echo '✅ Grafana is UP' || echo '❌ Grafana is DOWN'
                """
            }
        }
    }

    post {
        success {
            echo '🎉 Deployment successful! Weather App is live.'
        }
        failure {
            echo '💥 Deployment failed. Check the logs above.'
        }
        always {
            echo '📋 Pipeline finished. Cleaning up workspace...'
            cleanWs()
        }
    }
}
