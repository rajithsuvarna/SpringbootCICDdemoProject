pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@13.126.161.113'
        APP_DIR = 'springboot-cicd-demo'
        REPO_URL = 'https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git'
        DOCKER_IMAGE = 'springboot-cicd-demo'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'springboot-demo-container'
    }

    stages {
        stage('Build Locally on Windows') {
            steps {
                bat """
                    mvn clean package -DskipTests
                """
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    bat """
                        REM Remove inherited permissions
                        icacls "%SSH_KEY%" /inheritance:r

                        REM Grant full control to LocalSystem (Jenkins default service account)
                        icacls "%SSH_KEY%" /grant:r "NT AUTHORITY\\SYSTEM:F"

                        REM Remove overly permissive groups
                        icacls "%SSH_KEY%" /remove "BUILTIN\\Users"
                        icacls "%SSH_KEY%" /remove "Everyone"

                        REM Run deployment commands on EC2
                        ssh -v -i "%SSH_KEY%" -o StrictHostKeyChecking=no %EC2_HOST% ^
                            "sudo apt-get update -y && ^
                            sudo apt-get install -y docker.io git openjdk-17-jdk maven && ^
                            sudo systemctl start docker && ^
                            sudo systemctl enable docker && ^
                            sudo usermod -aG docker ubuntu && ^
                            if [ ! -d ${APP_DIR} ]; then git clone ${REPO_URL} ${APP_DIR}; else cd ${APP_DIR} && git pull; fi && ^
                            cd ${APP_DIR} && ^
                            mvn clean package -DskipTests && ^
                            docker stop ${CONTAINER_NAME} || true && ^
                            docker rm ${CONTAINER_NAME} || true && ^
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . && ^
                            docker run -d --name ${CONTAINER_NAME} -p 8085:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Deployment failed. Check EC2 logs.'
        }
    }
}
