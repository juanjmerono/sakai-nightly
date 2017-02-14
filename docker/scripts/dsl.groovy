import javaposse.jobdsl.dsl.DslScriptLoader
import javaposse.jobdsl.plugin.JenkinsJobManagement

def jobDslScript = """
	multibranchPipelineJob('SakaiNightlyPipeline') {
	    branchSources {
	        git {
	            remote('https://github.com/juanjmerono/sakai-nightly.git')
	        }
	    }
	    orphanedItemStrategy {
	        discardOldItems {
	            numToKeep(0)
	        }
	    }
	}
"""
def workspace = new File('.')

def jobManagement = new JenkinsJobManagement(System.out, [:], workspace)

new DslScriptLoader(jobManagement).runScript(jobDslScript)
