pipeline {
    agent any

    environment {
        IMAGE_NAME = "springboot-cicd-demo"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
               git branch: 'main', url: 'https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git'
            }
        }

        stage('Build JAR') {
            steps {
                sh './mvnw clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                sh '''
                docker stop springboot-container || true
                docker rm springboot-container || true
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                docker run -d --name springboot-container -p 8080:8080 ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }
}
