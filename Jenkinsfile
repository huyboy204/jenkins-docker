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
        ARTIFACT_VERS = "1.${env.BUILD_ID}"
        FAILED_STAGE_NAME = ""
        FAILED_STAGE_LOG = ""        
    }

    stages {
        stage('Unit Test with JUnit') {
            steps {
                sh './mvnw test'
            }
            post {
                failure {
                    // Archive the JUnit test results for later viewing in Jenkins
                    junit '**/target/surefire-reports/TEST-*.xml'
                    script {
                        FAILED_STAGE_NAME = "Unit Test with JUnit"
                        FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
                    }
                }
            }
        }
        
        stage('Check with SonarQube ') {
            when {
                branch 'main'
            }
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                withSonarQubeEnv('sonarqube-server') {
                   sh "'./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-${BRANCH_NAME} -Dsonar.projectName='Spring project ${BRANCH_NAME}'"
                }
            }
            post {
                failure {
                    script {
                        FAILED_STAGE_NAME = "Check with SonarQube with branch Main"
                        FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
                    }
                }
            }
        }

        // stage('Check with SonarQube with branch Dev') {
        //     when {
        //         branch 'dev'
        //     }
        //     steps {
        //         // Use SonarQube Scanner plugin to analyze your code. For example:
        //         withSonarQubeEnv('sonarqube-server') {
        //            sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-dev -Dsonar.projectName='Spring project dev'"
        //         }
        //     }
        //     post {
        //         failure {
        //             script {
        //                 FAILED_STAGE_NAME = "Check with SonarQube with branch Dev"
        //                 FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
        //             }
        //         }
        //     }
        // }

        // stage('Check with SonarQube with branch Feature') {
        //     when {
        //         branch 'feature'
        //     }
        //     steps {
        //         // Use SonarQube Scanner plugin to analyze your code. For example:
        //         withSonarQubeEnv('sonarqube-server') {
        //            sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-feature -Dsonar.projectName='Spring project feature'"
        //         }
        //     }
        //     post {
        //         failure {
        //             script {
        //                 FAILED_STAGE_NAME = "Check with SonarQube with branch Feature"
        //                 FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
        //             }
        //         }
        //     }
        // }

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
            post {
                failure {
                    script {
                        ${FAILED_STAGE_NAME} = "Push artifact to Nexus Repo"
                        ${FAILED_STAGE_LOG} = currentBuild.rawBuild.getLog(10000)
                    }
                }
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
            post {
                failure {
                    script {
                        ${FAILED_STAGE_NAME} = "Pull artifact on VM"
                        ${FAILED_STAGE_LOG} = currentBuild.rawBuild.getLog(10000)
                    }
                }
            }
        }

        stage('Deploy artifact') {
            when {
                branch 'main'
            }
            steps {
                sshagent(['sshagent-acc']) {
                    sh 'ssh root@192.168.56.120 systemctl restart web-Spring'
                }
            }
            post {
                failure {
                    script {
                        ${FAILED_STAGE_NAME} = "Deploy artifact"
                        ${FAILED_STAGE_LOG} = currentBuild.rawBuild.getLog(10000)
                    }
                }
            }
            
        }

        stage('Health check Web') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sleep(10)
                    def response = httpRequest url: 'http://192.168.56.120:8080'
                    println("Status: "+response.status)
                }
            }
            post {
                failure {
                    script {
                        ${FAILED_STAGE_NAME} = "Health check Web"
                        ${FAILED_STAGE_LOG} = currentBuild.rawBuild.getLog(10000)
                    }
                }
            }
        }
    }
    post {
        success {
            script {
                def slackMessage = "Pipeline result:\n"
                    slackMessage += "Jenkins Job: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n"
                    slackMessage += "Status: SUCCESS"
                // Send the Slack message
                slackSend color: currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger', message: slackMessage
            }
        }
        failure {
            script {
                def slackMessage = "Pipeline result:\n"
                    slackMessage += "Jenkins Job: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n"
                    slackMessage += "Failed Stage: ${FAILED_STAGE_NAME}\n"
                    slackMessage += "Stage Log:\n${FAILED_STAGE_LOG}"
                // Send the Slack message
                slackSend color: currentBuild.currentResult == 'SUCCESS' ? 'good' : 'danger', message: slackMessage
            }
        }
    }
}
