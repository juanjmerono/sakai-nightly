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

	// Read appropiate server name and other stuff
	def server_name = env.getProperty('SERVER_NAME_'+env.BRANCH_NAME)
	def sakai_db_user = env.getProperty('SAKAI_DB_USER')
	def sakai_db_pass = env.getProperty('SAKAI_DB_PASS')
	def sakai_db_name = env.getProperty('SAKAI_DB_NAME')
	def ethpad_host = env.getProperty('ETHERPAD_HOST')
	def ethpad_api_key = env.getProperty('ETHERPAD_API_KEY')

	if (server_name!=null) {

		stage ('Checkout Sakai Core') {
		   	// Checkout code from sakai repository
		   	dir('sakai') {
		   		git ( [url: 'https://github.com/sakaiproject/sakai.git', branch: env.BRANCH_NAME] )
		   	}
		}
		
		def patches_url = ethpad_host + '/p/' + server_name + '.patch/export/txt' 
		
		// Get the patches url's from a well-known place (etherpad, gist, gdoc,...)
		stage ('Get Patches') {
			try {
				sh "wget -O patch.properties ${patches_url}"
			} catch (e) {
				// Etherpad Patch File not exists
				println "No patch file available." 
			}
		}
		
		def props = readProperties file: 'patch.properties'
		def patches = props['PATCHES']!=null?props['PATCHES'].split(','):[]
		def errors = ''

	   	// Now apply patches dir:gh-user:branch
	   	stage ('Apply Patches') {
	   		// For each url apply patch
			for (int i=0; i<patches.size(); i++) {
				ghusrbch = patches[i].split(':')
				if (ghusrbch.size() == 3 && fileExists(ghusrbch[0])) {
			   		dir (ghusrbch[0]) {
			   			try {
							sh "curl https://github.com/${ghusrbch[1]}/compare/${ghusrbch[2]}.diff | git apply -v"
							errors = errors + '# Success applying [' + patches[i] + ']\n'
						} catch (e) {
				   			// Recover from patch fails and report somewhere
							errors = errors + '# Fail applying [' + patches[i] + ']: ' + e.toString() + '\n'
						}
			   		}
			   	} else {
			   		// Unexpected patch format !!
			   		errors = errors + '# Unexpected format [' + patches[i] + ']: Must be <dir:gh-user/repo:branch>\n'
			   	}
		   	}
		   	def results = '# Add here all the patches you want to apply to master server separated by comma\n' +
		   				  '# Use format: where:github-user:branch-name\n' +
		   				  'PATCHES=' + props['PATCHES'] + '\n' + errors
		   	try {
				sh "curl --data \"text=${results}&apikey=${ethpad_api_key}&padID=${server_name}.patch\" ${ethpad_host}/api/1/setText"
			} catch (e) {
				// Error returning to ethpad
				println results
				error("Can't write results to etherpad!!")
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
				// Remove database on monday
				// Week start on Sunday, and Month in 0
				if (today.get(Calendar.DAY_OF_WEEK)==2) {
					sh 'sudo docker-compose -p ' + env.BRANCH_NAME + ' down -v'
				} else {
					sh 'sudo docker-compose -p ' + env.BRANCH_NAME + ' stop'
				}
				dir ('tomcat') {
					// Clean tomcat deployment
					sh 'sudo rm -rf lib'
					sh 'sudo rm -rf components'
					sh 'sudo rm -rf webapps'
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
				withEnv(['SAKAI_SERVER_NAME=' + server_name,
						 'SAKAI_DB_USER=' + sakai_db_user,
						 'SAKAI_DB_PASS=' + sakai_db_pass,
						 'SAKAI_DB_NAME=' + sakai_db_name]) {
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
