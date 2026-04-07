pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'your-dockerhub-username/skill-hire'
        OPENSHIFT_SERVER = 'https://your-openshift-url'
        OPENSHIFT_CRED = 'openshift-credentials-id'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/MouliSaiDeep/skill-hire.git'
            }
        }

        stage('Build') {
            steps {
                dir('skill_hire') {
                    sh 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                dir('skill_hire') {
                    sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                    sh 'docker build -t ${DOCKER_IMAGE}:latest .'
                    withDockerRegistry([credentialsId: 'dockerhub-id', url: '']) {
                        sh 'docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}'
                        sh 'docker push ${DOCKER_IMAGE}:latest'
                    }
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                withKubeConfig([credentialsId: OPENSHIFT_CRED, serverUrl: OPENSHIFT_SERVER]) {
                    dir('openshift') {
                        sh 'kubectl apply -f mongodb-pvc.yaml'
                        sh 'kubectl apply -f mongodb-deployment.yaml'
                        sh 'kubectl apply -f mongodb-service.yaml'
                        sh 'kubectl apply -f skill-hire-deployment.yaml'
                        sh 'kubectl apply -f skill-hire-service.yaml'
                        sh 'kubectl apply -f skill-hire-route.yaml'
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
