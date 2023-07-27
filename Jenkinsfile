pipeline {
    agent any

    tools {
        jdk 'Java17'
    }

    environment {
        NEXUS_ACC = credentials('nexus-credential')
        NEXUS_URL = "192.168.56.103:8081"
        NEXUS_REPOSITORY = "java-repo"
        NEXUS_CREDENTIAL_ID = "nexus-credential"
        NEXUS_PRO_REPO = "java-repo"
        NEXUS_GROUP = "Product"
        NEXUS_ARTIFACT_ID = "Spring-RELEASE"
        ARTIFACT_VERS = "1.${env.BUILD_ID}-${new Date().format('yyMMdd-HHmm')}"
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
                    nexusUrl: "${NEXUS_URL}",
                    groupId: "${NEXUS_GROUP}",
                    version: "${ARTIFACT_VERS}",
                    repository: "${NEXUS_PRO_REPO}",
                    credentialsId: "${NEXUS_CREDENTIAL_ID}",
                    artifacts: [
                        [artifactId: "${NEXUS_ARTIFACT_ID}",
                        classifier: '',
                        file: './target/spring-petclinic-3.1.0-SNAPSHOT.jar',
                        type: 'jar']
                    ]
                )
            }
        }

        stage('Pull artifact on VM') {
            when {
                branch 'main'
            }
            steps {
                sshagent(['sshagent-acc']) {
                    sh 'ssh -o StrictHostKeyChecking=no root@192.168.56.120 curl -v -u $NEXUS_ACC_USR:$NEXUS_ACC_PSW -o /tmp/web-Spring.jar http://$NEXUS_URL/repository/$NEXUS_PRO_REPO/$NEXUS_GROUP/$NEXUS_ARTIFACT_ID/$ARTIFACT_VERS/$NEXUS_ARTIFACT_ID-$ARTIFACT_VERS.jar'
                }
            }
        }

        stage('Deploy artifact') {
            when {
                branch 'main'
            }
            steps {
                sshagent(['sshagent-acc']) {
                    //sh 'ssh root@192.168.56.120 java -jar /tmp/web-Spring.jar'
                    script {
                        ssh -o StrictHostKeyChecking=no -l root 192.168.56.120
                        nohup java -jar /tmp/web-Spring.jar
                    }
                }
            }
            
        }
    }
}
