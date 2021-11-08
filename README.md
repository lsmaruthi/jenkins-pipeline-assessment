# jenkins-pipeline-assessment

This project contains source code for a sample jenkins pipeline that does below
1) Validate Input from User.
2) Checkout source code of spring-petclinic project from github using SSH.
3) Using maven, compile spring-petclinic project.
4) Run unit tests.
5) Build a runnable Docker Image using the jar generated above.
6) Login to JFrog artifactory.
7) Push docker image to artifactory.
8) Perform clean up tasks like remove generated docker image from slave node and logout from artifactory.

Source Code 

- Jenkinsfile
- Dockerfile
	

Steps to configure this Github project in Jenkins 
	
	Pre-requisites:
	- Jenkins is running and had all the default recommended plugins installed.
	- Jdk 1.8 is installed 
	- Apache maven 3.8.3 is installed.
	- Docker is installed.
	- If using a slave, replace the label 'AWS-EC2-SLAVE' with your slave node otherwise use label as 'any'
	
	Credentials
	- Two Credentials are required here, one SSH based credentials to connect to Github and another username/password credentials to connect to JFrog artifactory.
	- Click 'Add Credentials', select Kind 'Username with Password', provide ID as 'JFROG_CREDENTIALS', provide username and password, click Add.
	- Click 'Add Credentials', select Kind 'SSH username with private key', provide ID as 'GITHUB_SSH_CREDENTIALS', provide username (ur github credentials), Paste the contents of private key registered in your github account. And Click 'Add'.	
	
	Steps:
	- Create a 'New Item', provide a name and select type as 'Pipeline'
	- Once created and in configure mode, click on 'Pipeline' tab, select 'Pipeline script from SCM'. In the repository url enter 'git@github.com:lsmaruthi/jenkins-pipeline-assessment.git'.
	- For credentials, From the dropdown choose 'GITHUB_SSH_CREDENTIALS'.
	- In Branches to build enter '*/main'
	- In additional behaviors add 'Clean before checkout' and 'Checkout to a sub-directory' with local sub-directory field value as 'scripts'.
	- In the script path enter 'Jenkinsfile'
	- Click 'Apply' and 'Save'
	- Run the Pipeline Job.

Steps to run the docker image 
	- Use this command to run the docker image
	
	docker container run -d -it -p 8080:8080 sowmyamaruthi.jfrog.io/default-docker-virtual/spring-petclinic:0.1
	
	
	

![Flow](https://user-images.githubusercontent.com/13734706/140831885-a2ce7abc-0b18-411b-b16e-e9d6cc118010.PNG)
