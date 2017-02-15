# Sakai Nightly Pipeline

Keep a test server updated.
This project allows you to use a Jenkins server to install a sakai server for testing purposes.

# Installation

You can run this pipeline with your own jenkins (2.x) server or deploy a custom jenkins with docker. If you use your own Jenkins you have to:

	- Add some plugins (see the complete list in docker/plugins.txt)
	- Add Maven3 and jdk8 tools.
	- Provide a docker installation accesible from jenkins.

If you want to deploy a custom jenkins server you only need docker/docker-compose installed and follow this steps:

	- Clone this repo.
	- Go to docker folder.
	- Add some oracle credentials in `variables.env` file in order to download jdk8.
		- ORACLE_USER=xxx
		- ORACLE_PASS=yyy
	- Ensure that you have /var/jenkins_home folder with permisions for UID 1000 (container jenkins user)
	- Type `docker-compose up -d`

# Run

After jenkins server is up you just have to create a Multibranch Pipeline Job to get a Sakai nightly server up and running.

	- Access to Jenkins server (admin/admin).
	- Create Multibranch Pipeline Job using this repo as git source.
	
 