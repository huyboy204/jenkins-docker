pipeline {
    agent any
    tools {
        jdk 'Java17'
    }
    stages {
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
                   sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-main -Dsonar.projectName='Spring project main'"
                }
            }
        }
    }
}
