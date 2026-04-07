pipeline {
    agent any
    tools {
        maven 'CSE_Maven'
        jdk 'java'
    }
    environment {
        BACKEND_IMAGE = 'moulisaideep/skill-hire'
        FRONTEND_IMAGE = 'moulisaideep/skill-hire-frontend'
        OPENSHIFT_SERVER = 'https://api.rm3.7wse.p1.openshiftapps.com:6443'
        OPENSHIFT_CRED = 'openshift-credentials-id'
    }

    stages {
        stage('Build Backend') {
            steps {
                dir('skill_hire') {
                    bat 'mvn clean package -DskipTests'
                }
            }
        }

        stage('Docker Build & Push Backend') {
            steps {
                dir('skill_hire') {
                    bat 'docker build -t %BACKEND_IMAGE%:%BUILD_NUMBER% .'
                    bat 'docker build -t %BACKEND_IMAGE%:latest .'
                    withDockerRegistry([credentialsId: 'dockerhub-id', url: '']) {
                        bat 'docker push %BACKEND_IMAGE%:%BUILD_NUMBER%'
                        bat 'docker push %BACKEND_IMAGE%:latest'
                    }
                }
            }
        }

        stage('Docker Build & Push Frontend') {
            steps {
                dir('frontend') {
                    bat 'docker build -t %FRONTEND_IMAGE%:%BUILD_NUMBER% .'
                    bat 'docker build -t %FRONTEND_IMAGE%:latest .'
                    withDockerRegistry([credentialsId: 'dockerhub-id', url: '']) {
                        bat 'docker push %FRONTEND_IMAGE%:%BUILD_NUMBER%'
                        bat 'docker push %FRONTEND_IMAGE%:latest'
                    }
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                withKubeConfig([credentialsId: OPENSHIFT_CRED, serverUrl: OPENSHIFT_SERVER]) {
                    dir('openshift') {
                        bat 'kubectl apply -f skill-hire-secrets.yaml'
                        bat 'kubectl apply -f skill-hire-deployment.yaml'
                        bat 'kubectl apply -f skill-hire-service.yaml'
                        bat 'kubectl apply -f skill-hire-route.yaml'
                        bat 'kubectl apply -f frontend-deployment.yaml'
                        bat 'kubectl apply -f frontend-service.yaml'
                        bat 'kubectl apply -f frontend-route.yaml'
                    }
                }
            }
        }
    }

    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed. Check logs.' }
    }
}