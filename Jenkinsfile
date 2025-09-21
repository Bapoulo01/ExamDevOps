pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-credentials'
        IMAGE_NAME = 'ahma98/exam-devops'
        IMAGE_TAG = 'latest'
        RENDER_API_KEY = credentials('render-credentials')
        RENDER_SERVICE_ID = 'srv-d37b997fte5s73b4lgjg'
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Bapoulo01/ExamDevOps.git'
            }
        }

        stage('Test Maven') {
            steps {
                bat 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build & Package') {
            steps {
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}", "--pull .")
                }
            }
        }

        stage('Push Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Render') {
            steps {
                echo "Déploiement sur Render via Docker..."
                script {
                    def imageName = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    echo "Image à déployer: ${imageName}"
                    
                    withCredentials([
                        string(credentialsId: 'render-api-key', variable: 'RENDER_API_KEY'),
                        string(credentialsId: 'render-service-id', variable: 'RENDER_SERVICE_ID')
                    ]) {
                        retry(3) {
                            powershell """
                                `$body = @{
                                    dockerImage = "${imageName}"
                                } | ConvertTo-Json
                                
                                `$headers = @{
                                    'Accept' = 'application/json'
                                    'Authorization' = "Bearer `$env:RENDER_API_KEY"
                                }
                                
                                try {
                                    `$response = Invoke-RestMethod `
                                        -Uri "https://api.render.com/v1/services/`$env:RENDER_SERVICE_ID/deploys" `
                                        -Method Post `
                                        -Headers `$headers `
                                        -Body `$body `
                                        -ContentType 'application/json'
                                    
                                    Write-Host "✅ Déploiement Render réussi!"
                                    Write-Host "ID du déploiement: `$(`$response.id)"
                                }
                                catch {
                                    Write-Host "❌ Erreur Render: `$(`$_.Exception.Message)"
                                    exit 1
                                }
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        failure {
            echo '❌ Build, test ou déploiement échoué'
        }
        success {
            echo '✅ Build, push Docker et déploiement Render terminés'
        }
    }
}