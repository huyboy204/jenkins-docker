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
                script {
                    try {
                        sh './mvnw test'
                    } catch (error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Unit Test with JUnit"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
                
            }
            // post {
            //     failure {
            //         // Archive the JUnit test results for later viewing in Jenkins
            //         junit '**/target/surefire-reports/TEST-*.xml'
            //         script {
            //             FAILED_STAGE_NAME = "Unit Test with JUnit"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }
        
        stage('Check with SonarQube ') {
            when {
                branch 'main'
            }
            steps {
                // Use SonarQube Scanner plugin to analyze your code. For example:
                script {
                    try {
                        withSonarQubeEnv('sonarqube-server') {
                            sh "./mvnw clean verify sonar:sonar -Dsonar.projectKey=Spring-project-${BRANCH_NAME} -Dsonar.projectName='Spring project ${BRANCH_NAME}'"
                        }
                    } catch (error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Check with SonarQube with branch ${BRANCH_NAME}"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
            // post {
            //     failure {
            //         script {
            //             FAILED_STAGE_NAME = "Check with SonarQube with branch ${BRANCH_NAME}"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }

        stage('Push artifact to Nexus Repo') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
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
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Push artifact to Nexus Repo"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
            // post {
            //     failure {
            //         script {
            //             FAILED_STAGE_NAME = "Push artifact to Nexus Repo"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }

        stage('Pull artifact on VM') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        sshagent(['sshagent-acc']) {
                            sh 'ssh -o StrictHostKeyChecking=no root@192.168.56.120 curl -v -u $NEXUS_ACC_USR:$NEXUS_ACC_PSW -o /tmp/web-Spring.jar http://$NEXUS_URL/repository/$NEXUS_PRO_REPO/$NEXUS_GROUP/$NEXUS_ARTIFACT_ID/$ARTIFACT_VERS/$NEXUS_ARTIFACT_ID-$ARTIFACT_VERS.jar'
                        }
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Pull artifact on VM"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
            // post {
            //     failure {
            //         script {
            //             FAILED_STAGE_NAME = "Pull artifact on VM"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }

        stage('Deploy artifact') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        sshagent(['sshagent-acc']) {
                            sh 'ssh root@192.168.56.120 systemctl restart web-Spring'
                        }
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Deploy artifact"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
                // sshagent(['sshagent-acc']) {
                //     sh 'ssh root@192.168.56.120 systemctl restart web-Spring'
                // }
            }
            // post {
            //     failure {
            //         script {
            //             FAILED_STAGE_NAME = "Deploy artifact"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }

        stage('Health check Web') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        sleep(10)
                        def response = httpRequest url: 'http://192.168.56.120:8080'
                        println("Status: "+response.status)
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Health check Web"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
            // post {
            //     failure {
            //         script {
            //             FAILED_STAGE_NAME = "Health check Web"
            //             FAILED_STAGE_LOG = currentBuild.rawBuild.getLog(10000)
            //         }
            //     }
            // }
        }
    }
    post {
        success {
            script {
                def slackMessage = "Pipeline result:\n"
                    slackMessage += "Jenkins Job: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n"
                    slackMessage += "Status: SUCCESS"
                // Send the Slack message
                slackSend color: 'good', message: slackMessage
            }
        }
        failure {
            script {
                def slackMessage = "Pipeline result:\n"
                    slackMessage += "Jenkins Job: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n"
                    slackMessage += "Failed Stage: ${FAILED_STAGE_NAME}\n"
                    slackMessage += "Failed Log: ${FAILED_STAGE_LOG}\n"
                // Send the Slack message
                slackSend color: 'danger', message: slackMessage
            }
        }
    }
}
