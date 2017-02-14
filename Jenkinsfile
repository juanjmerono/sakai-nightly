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
		// Start server
		dir ('docker/sakai') {
			sh 'sudo docker-compose up -d'
		}
	}
	
}
