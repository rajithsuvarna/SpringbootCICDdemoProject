pipeline {
    agent any

    environment {
        EC2_HOST = 'ubuntu@13.127.144.195'
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
                                scp -o StrictHostKeyChecking=no -i "$SSH_KEY" deploy.sh $EC2_HOST:/home/ubuntu/deploy.sh
                                ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no $EC2_HOST "chmod +x /home/ubuntu/deploy.sh && /home/ubuntu/deploy.sh"
                            '''
                        } else {
                            bat '''
                                icacls "%SSH_KEY%" /inheritance:r
                                icacls "%SSH_KEY%" /grant:r "NT AUTHORITY\\SYSTEM:F"
                                icacls "%SSH_KEY%" /remove "BUILTIN\\Users"
                                icacls "%SSH_KEY%" /remove "Everyone"

                                pscp -i "%SSH_KEY%" deploy.sh %EC2_HOST%:/home/ubuntu/deploy.sh
                                ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=no %EC2_HOST% "chmod +x /home/ubuntu/deploy.sh && /home/ubuntu/deploy.sh"
                            '''
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
