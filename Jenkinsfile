pipeline {
    agent any

    tools {
        jdk 'Java17'
    }

    environment {
        NEXUS_URL = "192.168.56.103:8081"
        NEXUS_REPOSITORY = "java-repo"
        NEXUS_CREDENTIAL_ID = "nexus-credential"
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
        
        stage('Check with SonarQube with branch Main') {
            when {
                branch 'main'
            }
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                withSonarQubeEnv('sonarqube-server') {
                   sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-main -Dsonar.projectName='Spring project main'"
                }
            }
        }

        stage('Check with SonarQube with branch Dev') {
            when {
                branch 'develop'
            }
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                withSonarQubeEnv('sonarqube-server') {
                   sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-dev -Dsonar.projectName='Spring project dev'"
                }
            }
        }

        stage('Check with SonarQube with branch Feature') {
            when {
                branch 'feature'
            }
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                withSonarQubeEnv('sonarqube-server') {
                   sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-feature -Dsonar.projectName='Spring project feature'"
                }
            }
        }

        stage('Push artifact to Nexus Repo') {
            when {
                branch 'main'
            }
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '$(NEXUS_URL)',
                    groupId: 'Product',
                    version: 'test',
                    repository: 'java-repo',
                    credentialsId: '$(NEXUS_CREDENTIAL_ID)',
                    artifacts: [
                        [artifactId: 'Spring-RELEASE',
                        classifier: '',
                        file: 'PetClinic-' + version + '.jar',
                        type: 'jar']
                    ]
                )
            }
        }
    }
}