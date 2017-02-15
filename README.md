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
	- Ensure that you have /var/jenkins_home folder with permisions for UID 1000 (container jenkins user)
	- Type `docker-compose up -d`

# Run

After jenkins server is up you just have to create a Multibranch Pipeline Job to get a Sakai nightly server up and running.

	- Access to Jenkins server (admin/admin).
	- Create Multibranch Pipeline Job using this repo as git source.
	
 