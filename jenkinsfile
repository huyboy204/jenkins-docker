pipeline {
    agent any
    tools {
        
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    git credentialsId: 'gitlab-credential', url: 'http://192.168.56.103:8929/spring-group/spring-project.git', branch: 'develop'
                }
            }
        }
        
        stage('Unit Test with JUnit') {
            steps {
                sh './mvnw test'
            }
            post {
                always {
                    // Archive the JUnit test results for later viewing in Jenkins
                    junit '**/target/surefire-reports/TEST-*.xml'
                }
            }
        }
        
        stage('Check with SonarQube') {
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                withSonarQubeEnv('sonarqube-server') {
                   sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-dev -Dsonar.projectName='Spring project dev'"
                }
            }
        }
    }
}
