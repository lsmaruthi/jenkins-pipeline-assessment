#!/usr/bin/groovy

properties([
	parameters([
		string(name: 'APP_NAME', defaultValue: 'spring-petclinic'),
		string(name: 'BRANCH', defaultValue: 'main'),
		string(name: 'GIT_REPO', defaultValue: 'spring-projects'),
		string(name: 'DOCKER_ARTIFACTORY_HOST', defaultValue: 'sowmyamaruthi.jfrog.io'),
		string(name: 'DOCKER_ARTIFACTORY_REPO', defaultValue: 'default-docker-virtual'),
		string(name: 'VERSION', defaultValue: '0.1')
	])
])

String app_name = params.APP_NAME ? params.APP_NAME.trim() : null
String branch_name = params.BRANCH ? params.BRANCH.trim() : null
String git_repo = params.GIT_REPO ? params.GIT_REPO.trim() : null
String docker_artifactory_host = params.DOCKER_ARTIFACTORY_HOST ? params.DOCKER_ARTIFACTORY_HOST.trim() : null
String docker_artifactory_repo = params.DOCKER_ARTIFACTORY_REPO ? params.DOCKER_ARTIFACTORY_REPO.trim() : null
String version = params.VERSION ? params.VERSION.trim() : null
String repo_url = "git@github.com:" + git_repo + "/" + app_name
String app_docker_image = "${docker_artifactory_host}/${docker_artifactory_repo}/${app_name}:${version}"

pipeline {
    agent { 
        node {
            label "AWS-EC2-SLAVE"			
        }		
    }
	environment {
		PATH="${PATH}:/jenkins/apache-maven-3.8.3/bin"
	}

    stages {
	
	    stage('Pre-requisites') {
			steps {
				script {
					try {
						dir("$WORKSPACE/scripts") {
							sh "git --version"
							sh "docker version"
							sh "mvn --version"
						}
					} catch (Exception ex) {
						println("exception in Pre-requisites stage")
						println("Exception: ${ex}")
					}					
				}					
			}
        }
		
		stage('Input Validation') {
			steps {
				script {
					def validation_list = ["app_name": app_name, "branch_name": branch_name, "git_repo": git_repo, "docker_artifactory_host": docker_artifactory_host, "docker_artifactory_repo": docker_artifactory_repo, "version": version]
					validation_list.each{ entry -> 
						println("Parameter: $entry.key Value: $entry.value")
						if(!entry.value) {
							echo "****User Input needed. Provide $entry.key ****"
							error("Validation failed..")
						}
					}
					echo "****All input validations are successful for the build****"
				}
			}
		}
		
		stage('Checkout source code from git') {
			steps {
				script {
					try {
						dir("$WORKSPACE/code") {						
							retry(5) {
								//git credentialsId: 'GITHUB_SSH_CREDENTIALS', url: repo_url, branch: branch_name
								git url: repo_url, branch: branch_name
							}							
						}
					} catch (Exception ex) {
						println("exception in project source code checkout stage")
						println("Exception: ${ex}")
					}					
				}			
			}
		}
		
		stage('Compile') {
			steps {
				script {
					try {
						dir("$WORKSPACE/code") {						
							//sh "mvn clean install -Dmaven.test.skip=true"	
							sh "./mvnw package"							
						}
					} catch (Exception ex) {
						println("exception in Compile stage")
						println("Exception: ${ex}")
					}
				}			
			}
		}
		
		stage('Test') {
			steps {
				script {
					try {
						dir("$WORKSPACE/code") {						
							sh "mvn test"						
						}
					} catch (Exception ex) {
						println("exception in Test stage")
						println("Exception: ${ex}")
					}
				}			
			}
		}
        
        /****
		// commenting this out as there is not enough memory & compute resources in provisioned free EC2 instance
		// this is a recommended approach to make builds faster.
		stage('Build') {
			failFast true
			parallel {
				stage('Compile') {
					steps {
						script {
							dir("$WORKSPACE/code") {						
								//sh "mvn clean install -Dmaven.test.skip=true"	
								sh "./mvnw package"							
							}
						}			
					}
				}
				stage('Test') {
					steps {
						script {
							dir("$WORKSPACE/code") {						
								sh "mvn test"						
							}
						}			
					}
				}
			}
        }
		****/
		
		stage('Artifactory Login') {
			steps {
				script {
					try {
						withCredentials([usernamePassword(credentialsId: 'JFROG_CREDENTIALS', usernameVariable: 'ARTIFACTORY_USER', passwordVariable: 'ARTIFACTORY_PASSWORD')]) {
							retry(5) {
								sh "docker login -u ${ARTIFACTORY_USER} -p ${ARTIFACTORY_PASSWORD} ${docker_artifactory_host}"
							}						
						}
					} catch (Exception ex) {
						println("exception in artifactory login stage")
						println("Exception: ${ex}")
					}										
				}			
			}
		
		}
		
		stage('Build Docker Image') {
            steps {
                script {
					try {
						dir("$WORKSPACE/scripts") {
							sh "cp $WORKSPACE/code/target/${app_name}*.jar ."
							sh "docker build --build-arg APP_NAME=${app_name} -t ${app_docker_image} ."
						}
					} catch (Exception ex) {
						println("exception in docker build stage")
						println("Exception: ${ex}")
					}					
				}
            }
        }		
		
		
		stage('Publish to Artifactory') {
            steps {
                script {
					try {
						retry(5) {
							sh "docker push ${app_docker_image}"
						}
					} catch (Exception ex) {
						println("exception in docker publish stage")
						println("Exception: ${ex}")
					}					
				}
            }
        }
    }
	post {
		always {
			script {
				sh "docker rmi ${app_docker_image}"
				sh "docker logout ${docker_artifactory_host}"
				echo "End of Stages"
			}
		}
		
		failure {
			script {
				echo "pipeline failed"				
			}
		}
		
		success {
			script {
				echo "pipeline success"				
			}
		}
		
		aborted {
			script {
				echo "pipeline aborted"				
			}
		}
	}
}