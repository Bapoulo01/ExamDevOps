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
                script {
                    // Définir le nom de l'image avec le numéro de build
                    def dockerImage = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    echo "🚀 Déploiement de: ${dockerImage}"
                    
                    // Utilisation de BAT pour Windows (plus fiable)
                    bat """
                        curl -X POST ^
                        "https://api.render.com/v1/services/srv-d37b997fte5s73b4lgjg/deploys" ^
                        -H "Authorization: Bearer rnd_bygkZpY5Gf73redc5mQEHt8WQvyy" ^
                        -H "Content-Type: application/json" ^
                        -d "{ \\"dockerImage\\": \\"${dockerImage}\\" }"
                        
                        if %errorlevel% equ 0 (
                            echo ✅ Déploiement Render réussi
                        ) else (
                            echo ❌ Erreur lors du déploiement
                            exit 1
                        )
                    """
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