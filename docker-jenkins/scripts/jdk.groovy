import jenkins.model.*
import hudson.model.*
import hudson.tools.*

def env = System.getenv()
def oracle_user = env['ORACLE_USER']
def oracle_pass = env['ORACLE_PASS']

def inst = Jenkins.getInstance()

def jdkDesc = inst.getDescriptor("hudson.model.JDK")
def instDesc = inst.getDescriptor("hudson.tools.JDKInstaller")

def versions = ["jdk8":"jdk-8u121-oth-JPR"]
def installations = [];

for (v in versions) {
  def installer = new JDKInstaller(v.value, true)
  def installerProps = new InstallSourceProperty([installer])
  def installation = new JDK(v.key, "", [installerProps])
  installations.push(installation)
}

println instDesc.doPostCredential('${oracle_user}','${oracle_pass}')
jdkDesc.setInstallations(installations.toArray(new JDK[0]))

jdkDesc.save()  
