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
			// mvn
			// Recover if fail
			for (int i=0; i<contribs.size(); i++) {
				ghurlbch = contribs[i].split(':')
				dir(ghurlbch[0]) {
					// mvn
				}
			}
		}			
	}   	
	
	// Now Stop server
	stage ('Stop Server') {
		// Stop server
		// Drop Database
		// Purge server files
		// Create Database
		// Create Sakai Properties
	}   	
	   	
	// Now deploy server
	stage ('Deploy to Server') {
		// Deploy sakai core
		dir ('sakai') {
			// mvn sakai:deploy
			withMaven
			// Deploy each contrib tool
			// Deploy mysql driver
		}
	}
	   	
	stage ('Start Server') {
	}
	
}
