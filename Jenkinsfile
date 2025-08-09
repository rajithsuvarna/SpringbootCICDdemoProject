pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'springboot-cicd-demo'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'springboot-demo-container'
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git'
            }
        }

        stage('Build JAR') {
            steps {
                echo 'Building Spring Boot application...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                echo 'Stopping old container if exists...'
                sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                """
            }
        }

        stage('Run Docker Container') {
            steps {
                echo 'Running new Docker container...'
                sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
