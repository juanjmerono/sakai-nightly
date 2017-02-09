properties([[$class: 'BuildDiscarderProperty',
                strategy: [$class: 'LogRotator', numToKeepStr: '5']],
                pipelineTriggers([cron('@midnight')]),
                ])

node {

	// Clean the workspace
	stage ('Cleanup') {
		step([$class: 'WsCleanup'])
	}

	// First checkout the code
	stage ('Checkout') {
	
		// Checkout the source from sakai-nightly.
		checkout scm
	   	// Checkout code from sakai repository
	   	dir('sakai') {
	   		git ( [url: 'https://github.com/sakaiproject/sakai.git', branch: env.BRANCH_NAME] )
	   	}
	   	
	}

	// Read properties after checkout
	def props = readProperties  file: 'nightly.properties'
	def tomcat_home = props['TOMCAT_HOME']
	def patches_url = props['PATCHES_URL']
	def db_name = props['DB_NAME']
	def service_name = props['SERVICE_NAME']
	def db_user = env.getEnvironment().get('DB_USER_${SERVICE_NAME}')
	def db_pass = env.getEnvironment().get('DB_PASS_${SERVICE_NAME}')

	// Get the patches url's from a well-known place (etherpad, gist, gdoc,...)
	stage ('Get Patches') {
		sh "wget ${patches_url} patch.properties"
	}
	
	def patch = readProperties file: 'patch.properties'
	def patches = props['PATCHES'].split(',')
	def contribs = props['CONTRIBS'].split(',')
		
   	// Now apply patches dir:gh-user:branch
   	stage ('Apply Patches') {
	   		// For each url spply patch
			for (int i=0; i<patches.size(); i++) {
				ghusrbch = patches[i].split(':')
		   		dir (ghusrbch[0]) {
					sh "curl https://github.com/${ghusrbch[1]}/sakai/compare/${ghusrbch[2]}.diff | git apply -v --index"
		   			// Recover from patch fails and report somewhere
		   		}
		   	}
		} 
	}
	
	// Now add contrib tools dir:gh-url:branch
   	stage ('Add Contrib Tools') {
   		dir ('sakai') {
	   		// For each url checkout inside sakai folder
			for (int i=0; i<contribs.size(); i++) {
				ghurlbch = contribs[i].split(':')
			   	dir(ghurlbch[0]) {
			   		git ( [url: 'https://github.com/'+ghurlbch[1]+'.git', branch: ghurlbch[2]] )
			   	}
		   	}
		}
   		// Recover from contrib fails and report somewhere
	}
	
	// Now build server
	stage ('Build Server') {
		dir ('sakai') {
			// Build main code
			withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
				sh "mvn clean install -B -V -DskipTests=true -Dmaven.javadoc.skip=true"
			}
			// Recover if fail
			for (int i=0; i<contribs.size(); i++) {
				ghurlbch = contribs[i].split(':')
				dir(ghurlbch[0]) {
					// Build contrib tool
					withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
						sh "mvn clean install -B -V -DskipTests=true -Dmaven.javadoc.skip=true"
					}
				}
			}
		}			
	}   	
	
	// Now Stop server
	stage ('Stop Server') {
		// Stop server
		sh 'sudo service ${service_name} stop'
		// Drop Database
		sh 'database.sh ${db_name} ${db_user} ${db_pass} ${service_name} drop'
		// Purge server files
		sh 'rm -rf ${tomcat_home}/webapps'
		sh 'rm -rf ${tomcat_home}/lib'
		sh 'mkdir ${tomcat_home}/lib'
		sh 'cp ${tomcat_home}/../tomcatlib/* ${tomcat_home}/lib/.'
		sh 'rm -rf ${tomcat_home}/components'
		sh 'rm -rf ${tomcat_home}/logs/*'
		sh 'rm -rf ${tomcat_home}/temp/*'
		sh 'rm -rf ${tomcat_home}/work/*'
		sh 'rm -rf /var/log/httpd/*.${service_name}.*.log'
		// Create Database
		sh 'database.sh ${db_name} ${db_user} ${db_pass} ${service_name} create'
		// Create Sakai Properties
	}   	
	   	
	// Now deploy server
	stage ('Deploy to Server') {
		// Deploy sakai core
		dir ('sakai') {
			// Deploy sakai core
			withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
				sh "mvn sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
			}
			// Recover if fail
			for (int i=0; i<contribs.size(); i++) {
				ghurlbch = contribs[i].split(':')
				dir(ghurlbch[0]) {
					// Build contrib tool
					withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
						sh "mvn sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
					}
				}
			}
			dir ('kernel/deploy/common') {
				// Deploy sakai core
				withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
					sh "mvn -Pmysql sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
				}
			}
		}
	}
	   	
	stage ('Start Server') {
		// Start server
		sh 'sudo service ${service_name} start'
	}
	
}
