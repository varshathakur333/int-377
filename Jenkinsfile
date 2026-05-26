pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Pulling latest code...'
                checkout scm
            }
        }

        stage('Verify Docker') {
            steps {
                echo 'Verifying Docker...'
                sh 'docker --version'
                sh 'docker compose version'
            }
        }

        stage('Build and Deploy') {
            steps {
                echo 'Building and deploying...'
                sh 'cp -r ${WORKSPACE}/. /home/ubuntu/app/'
                sh 'cd /home/ubuntu/app && docker compose down --remove-orphans || true'
                sh 'cd /home/ubuntu/app && docker compose up --build -d'
            }
        }

        stage('Health Check') {
            steps {
                echo 'Checking all services...'
                sh 'sleep 10'
                sh 'docker ps | grep weather-app && echo "Weather App UP" || echo "Weather App DOWN"'
                sh 'docker ps | grep grafana && echo "Grafana UP" || echo "Grafana DOWN"'
                sh 'docker ps | grep prometheus && echo "Prometheus UP" || echo "Prometheus DOWN"'
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed. Check logs.'
        }
        always {
            cleanWs()
        }
    }
}
