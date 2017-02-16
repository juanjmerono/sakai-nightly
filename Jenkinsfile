properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', numToKeepStr: '5']],
                pipelineTriggers([cron('@midnight')]),
                ])
node {

	def workspace = pwd()
	def today = Calendar.getInstance()

	// First checkout the code
	stage ('Checkout') {
		// Checkout the source from sakai-nightly.
		checkout scm
	}

	stage ('Checkout Sakai Core') {
	   	// Checkout code from sakai repository
	   	dir('sakai') {
	   		git ( [url: 'https://github.com/sakaiproject/sakai.git', branch: env.BRANCH_NAME] )
	   	}
	}
	
	// Now build server
	stage ('Build Sakai Core') {
		dir ('sakai') {
			// Build main code
			withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
				sh "mvn clean install -B -V -DskipTests=true -Dmaven.javadoc.skip=true"
			}
		}			
	}   	

	stage ('Stop and clean') {
		// Stop server 
		dir ('docker-sakai') {
			sh 'sudo docker-compose -p ' + env.BRANCH_NAME + ' stop'
			// Remove database on monday
			if (today.get(Calendar.DAY_OF_WEEK)==1) {
				sh 'sudo docker-compose -p ' + env.BRANCH_NAME + ' rm'
			}
			dir ('tomcat') {
				// Clean tomcat deployment
				// Tomcat decompress war with root user
				sh 'sudo rm -rf *'
			}
		}
		// remove exited containers:
		sh 'sudo docker ps --filter status=dead --filter status=exited -aq | xargs -r docker rm -v'
		// remove unused images:
		sh 'sudo docker images --no-trunc | grep \'<none>\' | awk \'{ print $3 }\' | xargs -r docker rmi'
		// remove unused volumes:
		sh 'sudo docker volume ls -qf dangling=true | xargs -r docker volume rm'
	}

	// Now deploy server
	stage ('Deploy Sakai Core') {
		// Deploy sakai core
		dir ('sakai') {
			// Deploy sakai core
			withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
				sh "mvn sakai:deploy -Dmaven.tomcat.home=${workspace}/docker-sakai/tomcat"
			}
			dir ('kernel/deploy/common') {
				// Deploy sakai core
				withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
					sh "mvn -Pmysql sakai:deploy -Dmaven.tomcat.home=${workspace}/docker-sakai/tomcat"
				}
			}
		}
	}

	stage ('Start Server') {
		// Start the new server
		dir ('docker-sakai') {
			withEnv(['SAKAI_SERVER_NAME=' + env.BRANCH_NAME + '.sakainightly.es']) {
				sh 'sudo -E docker-compose -p ' + env.BRANCH_NAME + ' up -d --force-recreate'
			}
		}
	}
	
}
