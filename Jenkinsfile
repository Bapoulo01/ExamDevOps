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
                    withCredentials([
                        string(credentialsId: 'RENDER_API_KEY', variable: 'RENDER_API_KEY'),
                        string(credentialsId: 'RENDER_SERVICE_ID', variable: 'RENDER_SERVICE_ID')
                    ]) {
                        retry(3) {
                            bat """
                                curl -X POST ^
                                    -H "Accept: application/json" ^
                                    -H "Authorization: Bearer %RENDER_API_KEY%" ^
                                    -d "{ \\"dockerImage\\": \\"${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}\\" }" ^
                                    "https://api.render.com/v1/services/%RENDER_SERVICE_ID%/deploys"
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