# Sakai Nightly Pipeline

Keep a test server updated.
This project creates a Jenkins installation with a Multibranch Pipeline Job, that deploy some test servers for Sakai.

# Installation

To deploy your custom jenkins server you only need docker/docker-compose installed and follow this steps:

	- Clone this repo.
	- Go to `docker-jenkins` folder.
	- Add some oracle credentials in `variables.env` file in order to download jdk8.
		- ORACLE_USER=xxx
		- ORACLE_PASS=yyy
	- Also add VIRTUAL_HOST variable with the domain of your jenkins server.
		- VIRTUAL_HOST=jenkins.mydomain
	- You're going to create one test server for each branch, so set the server name for that servers.
		- SERVER_NAME_<branch_name>=mybranch.mydomain
	- Add certs folder with all certificates for all servers if you want to use ssl.
		- jenkins.mydomain.crt,jenkins.mydomain.key,mybranch.mydomain.crt,...
		- If you don't want SSL at all add HTTPS_METHOD=nohttps in variables.env 
	- Ensure that you have /var/jenkins_home folder with permisions for UID 1000 (container jenkins user)
	- Type `docker-compose -p nightly up -d`

# Run

After jenkins server is up you just have to create a Multibranch Pipeline Job to get a Sakai nightly server up and running.

	- Access to Jenkins server (admin/admin).
	- Create Multibranch Pipeline Job using this repo as git source.
	
 