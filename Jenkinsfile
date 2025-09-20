pipeline {
    agent any

    tools {
        maven 'Maven-3.9'   // Nom configuré dans "Global Tool Configuration"
        jdk 'JDK-21'        // JDK installé dans Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: ''
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Archive Artifacts') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                junit 'target/surefire-reports/*.xml'
            }
        }
    }
}
