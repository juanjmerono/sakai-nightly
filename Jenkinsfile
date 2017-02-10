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
	}

	// Read properties after checkout
	def props = readProperties  file: 'nightly.properties'
	def tomcat_home = props['TOMCAT_HOME']
	def ethp_url = props['ETHERPAD_URL']
	def ethp_result = props['RESULT_PAD']
	def ethp_pad = props['PATCH_PAD']
	def patches_url = = etherpad_url + '/p/' + ethp_pad + '/export/txt' 
	def db_name = props['DB_NAME']
	def service_name = props['SERVICE_NAME']
	def db_user = env.getEnvironment().get('DB_USER_${SERVICE_NAME}')
	def db_pass = env.getEnvironment().get('DB_PASS_${SERVICE_NAME}')

	// Get the patches url's from a well-known place (etherpad, gist, gdoc,...)
	stage ('Get Patches') {
		sh "wget ${patches_url} patch.properties"
	}
	
	def patch = readProperties file: 'patch.properties'
	def patches = props['PATCHES']!=null?props['PATCHES'].split(','):[]
	def contribs = props['CONTRIBS']!=null?props['CONTRIBS'].split(','):[]
	def errors = ''

	stage ('Print Status') {
		echo "${}"		
	}
	
	stage ('Checkout Sakai Core') {
	   	// Checkout code from sakai repository
	   	dir('sakai') {
	   		git ( [url: 'https://github.com/sakaiproject/sakai.git', branch: env.BRANCH_NAME] )
	   	}
	}
	
	// Now add contrib tools dir:gh-url:branch
   	stage ('Checkout Contrib Tools') {
   		dir ('sakai') {
	   		// For each url checkout inside sakai folder
			for (int i=0; i<contribs.size(); i++) {
				ghurlbch = contribs[i].split(':')
				if (ghurlbch.size() == 3) {
				   	dir(ghurlbch[0]) {
				   		try {
				   			git ( [url: 'https://github.com/'+ghurlbch[1]+'.git', branch: ghurlbch[2]] )
				   		} catch (e) {
				   			// Recover from contrib fails and report somewhere
				   			errors = errors + 'Fail downloading [' + contribs[i] + ']: ' + e.toString() + '\n'
				   		}
				   	}
				} else {
			   		// Unexpected contrib format !!
			   		errors = errors + 'Unexpected contrib [' + contribs[i] + ']: Must be <dir:gh-url:branch>\n'
				}
		   	}
		}
	}
	
   	// Now apply patches dir:gh-user:branch
   	stage ('Apply Patches') {
	   		// For each url apply patch
			for (int i=0; i<patches.size(); i++) {
				ghusrbch = patches[i].split(':')
				if (ghusrbch.size() == 3 && fileExists(ghusrbch[0])) {
			   		dir (ghusrbch[0]) {
			   			try {
							sh "curl https://github.com/${ghusrbch[1]}/compare/${ghusrbch[2]}.diff | git apply -v --index"
						} catch (e) {
				   			// Recover from patch fails and report somewhere
							errors = errors + 'Fail applying [' + patches[i] + ']: ' + e.toString() + '\n'
						}
			   		}
			   	} else {
			   		// Unexpected patch format !!
			   		errors = errors + 'Unexpected format [' + patches[i] + ']: Must be <dir:gh-user:branch>\n'
			   	}
		   	}
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

	// Now build contrib tools
	stage ('Build Contrib Tools') {
   		// For each url build code
		for (int i=0; i<contribs.size(); i++) {
			ghurlbch = contribs[i].split(':')
			if (ghurlbch.size() == 3 && fileExists(ghusrbch[0])) {
			   	dir(ghurlbch[0]) {
			   		try {
						withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
							sh "mvn clean install -B -V -DskipTests=true -Dmaven.javadoc.skip=true"
						}
			   		} catch (e) {
			   			// Recover from contrib fails and report somewhere
			   			errors = errors + 'Fail building [' + contribs[i] + ']: ' + e.toString() + '\n'
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
	stage ('Deploy Sakai Core') {
		// Deploy sakai core
		dir ('sakai') {
			// Deploy sakai core
			withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
				sh "mvn sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
			}
			dir ('kernel/deploy/common') {
				// Deploy sakai core
				withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
					sh "mvn -Pmysql sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
				}
			}
		}
	}

	// Now deploy server
	stage ('Deploy Sakai Core') {
   		// For each url build code
		for (int i=0; i<contribs.size(); i++) {
			ghurlbch = contribs[i].split(':')
			if (ghurlbch.size() == 3 && fileExists(ghusrbch[0])) {
			   	dir(ghurlbch[0]) {
			   		try {
						withMaven(maven:'Maven3',jdk:'jdk8',mavenOpts:'-Xmx768m -XX:MaxPermSize=512m -XX:NewSize=256m') {
							sh "mvn sakai:deploy -Dmaven.tomcat.home=${tomcat_home}"
						}
			   		} catch (e) {
			   			// Recover from contrib fails and report somewhere
			   			errors = errors + 'Fail deploying [' + contribs[i] + ']: ' + e.toString() + '\n'
			   		}
			   	}
			}
	   	}
	}
	   	
	stage ('Start Server') {
		// Start server
		sh 'sudo service ${service_name} start'
	}
	
	stage ('Report Information') {
		// Write on etherpad
		sh "curl --data \"text=${errors}&apikey=${env.ETHP_API_KEY}&padID=${ethp_result}\" ${ethp_url}/api/1/setText"	
	}
	
}
