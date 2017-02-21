# Sakai Nightly Pipeline

Keep a test server updated.
This project creates a Jenkins installation with a Multibranch Pipeline Job, that deploy some test servers for Sakai.

# Installation

To deploy your custom jenkins server you only need docker/docker-compose installed and follow this steps:

	- Clone this repo.
	- Go to `docker-jenkins` folder.
	- Create `variables.env` file to customize your deployment.  (See demo_variables.env file)
		- Add some oracle credentials in order to download jdk8.
			- ORACLE_USER=xxx
			- ORACLE_PASS=yyy
		- Add Etherpad configuration.
			- ETHPAD_URL=...
			- ETHPAD_API_KEY=...
		- Also add VIRTUAL_HOST variable with the domain of your jenkins server.
			- VIRTUAL_HOST=jenkins.mydomain
		- You're going to create one test server for each branch, so set the server name for that servers.
			- SERVER_NAME_<branch_name>=mybranch.mydomain
		- Also configure database names:
			- SAKAI_DB_USER, SAKAI_DB_PASS and SAKAI_DB_NAME
	- Add certs folder with all certificates for all servers if you want to use ssl.
		- jenkins.mydomain.crt,jenkins.mydomain.key,mybranch.mydomain.crt,...
		- If you don't want SSL at all add HTTPS_METHOD=nohttps in variables.env
	- Ensure that you have /opt/jenkins_home and /opt/jenkins folders with permisions for UID 1000 (container jenkins user)
		- The `jenkins_home` will contain every job workspace. 
		- The `jenkins` folder will contain the .m2 repository.
	- Type `docker-compose -p nightly up -d`
		- `nightly` name is important, the network is based on that name.

# Run

After jenkins server is up you just have to run Multibranch Pipeline Job to get a Sakai nightly server for each branch up and running.
	
 