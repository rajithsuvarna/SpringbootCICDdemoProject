pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@65.0.29.129'
        APP_DIR = 'springboot-cicd-demo'
        REPO_URL = 'https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git'
        DOCKER_IMAGE = 'springboot-cicd-demo'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'springboot-demo-container'
    }

    stages {
        stage('Deploy to EC2') {
            steps {
                // Use SSH private key directly from Jenkins credentials
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                    ssh -i $SSH_KEY -o StrictHostKeyChecking=no ${EC2_HOST} '
                        # Install prerequisites
                        sudo apt-get update -y &&
                        sudo apt-get install -y docker.io git openjdk-17-jdk maven &&
                        sudo systemctl start docker &&
                        sudo systemctl enable docker &&
                        sudo usermod -aG docker ubuntu &&

                        # Get latest source code
                        if [ ! -d ${APP_DIR} ]; then
                            git clone ${REPO_URL} ${APP_DIR};
                        else
                            cd ${APP_DIR} && git pull;
                        fi &&

                        # Build and run Docker
                        cd ${APP_DIR} &&
                        mvn clean package -DskipTests &&
                        docker stop ${CONTAINER_NAME} || true &&
                        docker rm ${CONTAINER_NAME} || true &&
                        docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . &&
                        docker run -d --name ${CONTAINER_NAME} -p 8081:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}
                    '
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
