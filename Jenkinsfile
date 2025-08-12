pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@13.127.144.195'
        APP_DIR = 'springboot-cicd-demo'
        REPO_URL = 'https://github.com/rajithsuvarna/SpringbootCICDdemoProject.git'
        DOCKER_IMAGE = 'springboot-cicd-demo'
        DOCKER_TAG = 'latest'
        CONTAINER_NAME = 'springboot-demo-container'
    }

    stages {
        stage('Build Locally') {
            steps {
                script {
                    if (isUnix()) {
                        sh 'mvn clean package -DskipTests'
                    } else {
                        bat 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                                chmod 600 "$SSH_KEY"
                                ssh -v -i "$SSH_KEY" -o StrictHostKeyChecking=no $EC2_HOST '
                                    sudo apt-get update -y &&
                                    sudo apt-get install -y docker.io git openjdk-17-jdk maven &&
                                    sudo systemctl start docker &&
                                    sudo systemctl enable docker &&
                                    sudo usermod -aG docker ubuntu &&
                                    if [ ! -d ${APP_DIR} ]; then git clone ${REPO_URL} ${APP_DIR}; else cd ${APP_DIR} && git pull; fi &&
                                    cd ${APP_DIR} &&
                                    chmod +x deploy.sh &&
                                    ./deploy.sh
                                '
                            '''
                        } else {
                            bat """
                                icacls "%SSH_KEY%" /inheritance:r
                                icacls "%SSH_KEY%" /grant:r "NT AUTHORITY\\SYSTEM:F"
                                icacls "%SSH_KEY%" /remove "BUILTIN\\Users"
                                icacls "%SSH_KEY%" /remove "Everyone"

                                ssh -v -i "%SSH_KEY%" -o StrictHostKeyChecking=no %EC2_HOST% ^
                                    "sudo apt-get update -y && ^
                                    sudo apt-get install -y docker.io git openjdk-17-jdk maven && ^
                                    sudo systemctl start docker && ^
                                    sudo systemctl enable docker && ^
                                    sudo usermod -aG docker ubuntu && ^
                                    if [ ! -d ${APP_DIR} ]; then git clone ${REPO_URL} ${APP_DIR}; else cd ${APP_DIR} && git pull; fi && ^
                                    cd ${APP_DIR} && ^
                                    chmod +x deploy.sh && ^
                                    ./deploy.sh"
                            """
                        }
                    }
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
