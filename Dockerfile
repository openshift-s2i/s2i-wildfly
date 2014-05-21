# centos-wildfly-standalone
#
# This image provides a base for building and running wildfly applications.
# It builds using maven and runs the resulting artifacts on wildfly 8.1.

FROM centos

MAINTAINER Ben Parees <bparees@redhat.com>

# Execute update && install in one yum command.
#
RUN ( \
      echo "update"; \
      echo "install tar unzip which bc"; \
      echo "install java-1.7.0-openjdk java-1.7.0-openjdk-devel"; \
      echo "run"; \
    ) | yum shell -y && yum clean all -y

# Install Maven, Wildfly 8 and sample JEE application
# The sample application will be built/run if no other source is bind-mounted to mask it.
#
RUN (curl -0 http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz | \
    tar -zx -C /usr/local) && ln -sf /usr/local/apache-maven-3.0.5/bin/mvn /usr/local/bin/mvn && \
    mkdir -p /wildfly && (curl -0 http://download.jboss.org/wildfly/8.1.0.CR1/wildfly-8.1.0.CR1.tar.gz | \
    tar -zx --strip-components=1 -C /wildfly) && /wildfly/bin/add-user.sh admin passw0rd_ --silent && \
    mkdir /tmp/src && (curl -L0 https://github.com/bparees/openshift-jee-sample/archive/master.tar.gz | \
    tar -zx -C /tmp/src --strip-components=1 ) && mkdir -p /opt/wildfly/source

ADD ./wfmodules/ /wildfly/modules/

# Configure Source-To-Image scripts
ADD ./bin /usr/bin/

ENV STI_SCRIPTS_URL https://raw.githubusercontent.com/openshift/wildfly-8-centos/master/.sti/bin

# Add geard/sti wildfly customizations
ADD ./wfbin/standalone.conf /wildfly/bin/standalone.conf
ADD ./wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml

WORKDIR /opt/wildfly/source

# Create wildfly group and user, set file ownership to that user.
RUN groupadd -r wildfly -g 433 && \
    useradd -u 431 -r -g wildfly -d /opt/wildfly -s /sbin/nologin -c "Wildfly user" wildfly && \
    chown -R wildfly:wildfly /wildfly && \
    chown -R wildfly:wildfly /opt/wildfly && \
    chown -R wildfly:wildfly /tmp/src

USER wildfly
EXPOSE 7600 8080 9990 9999
CMD /usr/bin/usage
