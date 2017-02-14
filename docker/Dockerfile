FROM jenkins:latest

USER root
RUN apt-get update \
      && apt-get install -y sudo \
      && rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

USER jenkins
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY scripts/executors.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY scripts/default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY scripts/maven.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY scripts/jdk.groovy /usr/share/jenkins/ref/init.groovy.d/
COPY scripts/dsl.groovy /usr/share/jenkins/ref/init.groovy.d/