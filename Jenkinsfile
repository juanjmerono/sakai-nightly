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

	// Read appropiate server name
	def server_name = env.getProperty('SERVER_NAME_'+env.BRANCH_NAME)

	if (server_name!=null) {

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
					sh 'sudo docker-compose -p ' + env.BRANCH_NAME + ' rm -f -v'
				}
				dir ('tomcat') {
					// Clean tomcat deployment
					// Tomcat decompress war with root user
					sh 'sudo rm -rf *'
				}
			}
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
				withEnv(['SAKAI_SERVER_NAME=' + server_name ]) {
					sh 'sudo -E docker-compose -p ' + env.BRANCH_NAME + ' up -d --force-recreate'
				}
			}
		}
		
	} else {
	
		stage ('Skip Branch') {
			println 'Skipping branch ' + env.BRANCH_NAME + ' not server name detected: ' + server_name
		}
	
	}	
	
}
