pipeline {
    agent any  

    environment {
        DOCKER_HUB_REPO = 'ahma98/exam-devops'
        IMAGE_TAG = "latest" 
        RENDER_SERVICE_ID = 'srv-d37b997fte5s73b4lgjg'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm 
            }
        }

      

        stage('Build Docker Image') {
            steps {
                script {
                    def customImage = bat "docker build --load -t ${env.DOCKER_HUB_REPO}:${env.IMAGE_TAG} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub_credential') {
                        def image = docker.image("${env.DOCKER_HUB_REPO}:${env.IMAGE_TAG}")
                        image.push()
                        image.push('latest') 
                    }
                }
            }
        }

        stage('Deploy to Render') {
            steps {
                script {
                    sh """
                        curl -X POST \
                            -H "Authorization: Bearer \${render_api}" \
                            -H "Content-Type: application/json" \
                            https://api.render.com/v1/services/\${RENDER_SERVICE_ID}/deploys
                    """
                }
            }
        }
    }

    post {
        always {
            sh script: 'docker rmi ${DOCKER_HUB_REPO}:${IMAGE_TAG} || true'
        }
        success {
            echo 'Pipeline réussi ! Image pushée et déployée sur Render.'
        }
        failure {
            echo 'Pipeline échoué. Vérifiez les logs.'
        }
    }
}