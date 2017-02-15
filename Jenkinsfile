properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', numToKeepStr: '5']],
                ])
node {

	def workspace = pwd()

	// First checkout the code
	stage ('Checkout') {
		// Checkout the source from sakai-nightly.
		checkout scm
	}

	stage ('Checkout Sakai Core') {
		dir ('docker') {
			git ( [url: 'https://github.com/juanjmerono/docker-sakai.git', branch: env.BRANCH_NAME] )
		}
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
		dir ('docker/sakai') {
			sh 'sudo docker-compose stop'
			sh 'sudo docker-compose rm'
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
				sh "mvn sakai:deploy -Dmaven.tomcat.home=${workspace}/docker/sakai/tomcat"
			}
			dir ('kernel/deploy/common') {
				// Deploy sakai core
				withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
					sh "mvn -Pmysql sakai:deploy -Dmaven.tomcat.home=${workspace}/docker/sakai/tomcat"
				}
			}
		}
	}

	stage ('Start Server') {
		// Start the new server
		dir ('docker/sakai') {
			sh 'sudo docker-compose up -d'
		}
	}
	
}
