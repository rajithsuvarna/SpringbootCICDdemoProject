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
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    script {
                        // Create a temporary key file with correct permissions
                        def tempKey = "${env.WORKSPACE}\\temp_key"
                        bat """
                            copy "%SSH_KEY%" "${tempKey}"
                            icacls "${tempKey}" /reset
                            icacls "${tempKey}" /inheritance:r
                            icacls "${tempKey}" /grant:r "%USERNAME%":F
                            icacls "${tempKey}" /remove "BUILTIN\\Users"
                            icacls "${tempKey}" /remove "Everyone"
                            icacls "${tempKey}"
                        """

                        // Prepare commands
                        def commands = """
                            sudo apt-get update -y &&
                            sudo apt-get install -y docker.io git openjdk-17-jdk maven &&
                            sudo systemctl start docker &&
                            sudo systemctl enable docker &&
                            sudo usermod -aG docker ubuntu &&
                            if [ ! -d ${APP_DIR} ]; then git clone ${REPO_URL} ${APP_DIR}; else cd ${APP_DIR} && git pull; fi &&
                            cd ${APP_DIR} &&
                            mvn clean package -DskipTests &&
                            (docker stop ${CONTAINER_NAME} || true) &&
                            (docker rm ${CONTAINER_NAME} || true) &&
                            docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} . &&
                            docker run -d --name ${CONTAINER_NAME} -p 8085:8080 ${DOCKER_IMAGE}:${DOCKER_TAG}
                        """.replace('\n', ' ').trim()

                        // Execute SSH with the temporary key
                        bat """
                            ssh -i "${tempKey}" -o StrictHostKeyChecking=no %EC2_HOST% "${commands}"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                // Clean up temporary key
                bat """
                    if exist "${env.WORKSPACE}\\temp_key" (
                        del /F /Q "${env.WORKSPACE}\\temp_key"
                    )
                """
            }
        }
        failure {
            echo '❌ Deployment failed. Check EC2 logs.'
        }
        success {
            echo '✅ Deployment successful!'
        }
    }
}