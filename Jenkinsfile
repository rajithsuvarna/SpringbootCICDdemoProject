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
        stage('Install PuTTY Tools') {
            steps {
                bat '''
                    if not exist "C:\\Program Files\\PuTTY" (
                        echo Installing PuTTY...
                        curl -o putty.exe -L https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe
                        curl -o plink.exe -L https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe
                        start /wait putty.exe /silent
                        move plink.exe "C:\\Windows\\System32"
                    )
                '''
            }
        }

        stage('Build Locally on Windows') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Fix SSH Key Permissions') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    bat """
                        icacls "%SSH_KEY%" /reset
                        icacls "%SSH_KEY%" /inheritance:r
                        icacls "%SSH_KEY%" /grant:r "%USERNAME%":F
                        icacls "%SSH_KEY%" /remove "BUILTIN\\Users"
                        icacls "%SSH_KEY%" /remove "Everyone"
                    """
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    bat """
                        echo y | plink -i "%SSH_KEY%" -ssh %EC2_HOST% ^
                            "sudo apt-get update -y && ^
                            sudo apt-get install -y docker.io git openjdk-17-jdk maven && ^
                            sudo systemctl start docker && ^
                            sudo systemctl enable docker && ^
                            sudo usermod -aG docker ubuntu && ^
                            if [ ! -d ${APP_DIR} ]; then git clone ${REPO_URL} ${APP_DIR}; else cd ${APP_DIR} && git pull; fi && ^
                            cd ${APP_DIR} && ^
                            mvn clean package -DskipTests && ^
                            (docker stop ${CONTAINER_NAME} || true) && ^
                            (docker rm ${CONTAINER_NAME} || true) && ^
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . && ^
                            docker run -d --name ${CONTAINER_NAME} -p 8085:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}"
                    """
                }
            }
        }
    }

    post {
        failure {
            echo '❌ Deployment failed. Check EC2 logs.'
        }
        success {
            echo '✅ Deployment successful!'
        }
    }
}