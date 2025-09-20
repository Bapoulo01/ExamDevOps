pipeline {
    agent any

    tools {
        jdk 'Java-21'
        maven 'Maven-3.9'
    }

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-credentials'
        IMAGE_NAME = 'ahma98/exam-devops'
        IMAGE_TAG = 'latest'
        RENDER_API_KEY = credentials('render-credentials')
        RENDER_SERVICE_ID = 'srv-d37b997fte5s73b4lgjg'
    }

    stages {

//         stage('Checkout') {
//             steps {
//                 git branch: 'main', url: 'https://github.com/Bapoulo01/ExamDevOps.git'
//             }
//         }

        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/Bapoulo01/ExamDevOps.git']]
                ])
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
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
                sh """
                   curl -X POST \\
                   -H "Accept: application/json" \\
                   -H "Authorization: Bearer ${RENDER_API_KEY}" \\
                   -d '{ "dockerImage": "${IMAGE_NAME}:${IMAGE_TAG}" }' \\
                   https://api.render.com/v1/services/${RENDER_SERVICE_ID}/deploys
                """
            }
        }
    }

    post {
        failure {
            echo '❌ Build ou déploiement échoué'
        }
        success {
            echo '✅ Build, push Docker et déploiement Render terminés'
        }
    }
}