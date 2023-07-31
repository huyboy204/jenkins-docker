pipeline {
    agent any

    tools {
        jdk 'Java17'
    }

    environment {
        NEXUS_ACC = credentials('nexus-credential')
        NEXUS_URL = "192.168.56.103:8081"
        NEXUS_URL2 = "192.168.56.103:8082"
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
        }

        stage('Build docker image') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        sh "docker build -t ${NEXUS_URL2}/web:${ARTIFACT_VERS} ."
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Build docker image"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
        }

        stage('Push docker image to Nexus Repo') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'nexus-credential', passwordVariable: 'PSW', usernameVariable: 'USER')]){
                            sh 'echo $PSW | docker login -u $USER --password-stdin $NEXUS_URL2'
                            sh "docker push ${NEXUS_URL2}/web:${ARTIFACT_VERS}"
                        }
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Push docker image to Nexus Repo"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
                    }
                }
            }
        }

        stage('Deploy artifact') {
            when {
                branch 'main'
            }
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'nexus-credential', passwordVariable: 'PSW', usernameVariable: 'USER')]){
                            sshagent(['ssh-vm-docker']) {
                            sh '
                                ssh root@192.168.56.103 \ echo $PSW | docker login -u $USER --password-stdin $NEXUS_URL2 \ docker run -d -p 8080:8080 $NEXUS_URL2/web:$ARTIFACT_VERS'
                        }
                        }
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Deploy artifact"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
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
                    try {
                        sleep(10)
                        def response = httpRequest url: 'http://192.168.56.103:8080'
                        println("Status: "+response.status)
                    } catch(error) {
                        echo "Error occurred while Running. Message : ${error.getMessage()}"
                        FAILED_STAGE_NAME = "Health check Web"
                        FAILED_STAGE_LOG = "${error.getMessage()}"
                        throw error
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
                    slackMessage += "Status: SUCCESS\n"
                    slackMessage += "${BUILD_URL}"
                // Send the Slack message
                slackSend color: 'good', message: slackMessage
            }
            mail to: "huyboy204@gmail.com",
            subject: "${JOB_NAME} - Build # ${BUILD_NUMBER} - SUCCESS!",
            body: "Check console output at ${BUILD_URL} to view the results."
        }
        failure {
            script {
                def slackMessage = "Pipeline result:\n"
                    slackMessage += "Jenkins Job: ${env.JOB_NAME} - ${env.BUILD_NUMBER}\n"
                    slackMessage += "Failed Stage: ${FAILED_STAGE_NAME}\n"
                    slackMessage += "Failed Log: ${FAILED_STAGE_LOG}\n"
                    slackMessage += "${BUILD_URL}"
                // Send the Slack message
                slackSend color: 'danger', message: slackMessage
            }
            mail to: "huyboy204@gmail.com",
            subject: "${JOB_NAME} - Build # ${BUILD_NUMBER} - FAILURE!",
            body: "Failed Log: ${FAILED_STAGE_LOG}. Check console output at ${BUILD_URL} to view the results."
        }
    }
}
