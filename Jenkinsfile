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
            }
        }

        stage('Build and Deploy') {
            steps {
                echo 'Building and deploying...'
                sh 'docker stop weather-app || true'
                sh 'docker rm weather-app || true'
                sh 'docker build -t app-weather-app .'
                sh 'docker run -d -p 80:80 --name weather-app --network app_weather-net app-weather-app'
            }
        }

        stage('Health Check') {
            steps {
                echo 'Checking all services...'
                sh 'sleep 5'
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
