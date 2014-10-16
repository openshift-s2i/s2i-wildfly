# centos-wildfly-standalone
#
# This image provides a base for building and running wildfly applications.
# It builds using maven and runs the resulting artifacts on wildfly 8.1.

FROM centos:centos7

RUN yum install -y --enablerepo=centosplus \
    tar unzip bc which lsof java-1.7.0-openjdk java-1.7.0-openjdk-devel && \
    yum clean all -y

# Install Maven, Wildfly 8 and sample JEE application
# The sample application will be built/run if no other source is bind-mounted to mask it.
#
RUN (curl -0 http://mirror.cc.columbia.edu/pub/software/apache/maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz | \
    tar -zx -C /usr/local) && ln -sf /usr/local/apache-maven-3.0.5/bin/mvn /usr/local/bin/mvn && \
    mkdir -p /wildfly && (curl -0 http://download.jboss.org/wildfly/8.1.0.Final/wildfly-8.1.0.Final.tar.gz | \
    tar -zx --strip-components=1 -C /wildfly) && mkdir -p /opt/wildfly/source

ADD ./wfmodules/ /wildfly/modules/

# Configure Source-To-Image scripts
ADD ./bin /usr/bin/
ADD ./.sti/bin/usage /usr/bin/

ENV STI_SCRIPTS_URL https://raw.githubusercontent.com/openshift/wildfly-8-centos/master/.sti/bin

# Add sti wildfly customizations
ADD ./wfbin/standalone.conf /wildfly/bin/standalone.conf
ADD ./wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml

# Create wildfly group and user, set file ownership to that user.
RUN groupadd -r wildfly -g 433 && \
    useradd -u 431 -r -g wildfly -d /opt/wildfly -s /sbin/nologin -c "Wildfly user" wildfly && \
    chown -R wildfly:wildfly /wildfly && \
    chown -R wildfly:wildfly /opt/wildfly

ENV HOME /opt/wildfly

WORKDIR /opt/wildfly/source

USER wildfly

EXPOSE 7600 8080 8787 9990 9999

CMD ["/usr/bin/sti-helper"]
