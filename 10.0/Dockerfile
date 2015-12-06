# This image provides a base for building and running WildFly applications.
# It builds using maven and runs the resulting artifacts on WildFly 10.0.0 CR4

FROM openshift/base-centos7

MAINTAINER Ben Parees <bparees@redhat.com>

EXPOSE 8080

ENV WILDFLY_VERSION 10.0.0.CR4
ENV WILDFLY_VERSION_BIN 10.0.0.CR4
ENV MAVEN_VERSION 3.3.3

LABEL io.k8s.description="Platform for building and running JEE applications on WildFly 10.0.0.CR4" \
      io.k8s.display-name="WildFly 10.0.0.CR4" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,wildfly,wildfly10" \
      io.openshift.s2i.destination="/opt/s2i/destination"

# Install Maven, Wildfly 10
RUN yum install -y --enablerepo=centosplus \
    tar unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel && \
    yum clean all -y && \
    (curl -0 http://www.us.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p /wildfly && \
    (curl -0 http://download.jboss.org/wildfly/$WILDFLY_VERSION_BIN/wildfly-$WILDFLY_VERSION_BIN.tar.gz | tar -zx --strip-components=1 -C /wildfly) && \
    mkdir -p /opt/s2i/destination

# Add sti wildfly customizations
ADD ./contrib/wfmodules/ /wildfly/modules/
ADD ./contrib/wfbin/standalone.conf /wildfly/bin/standalone.conf
ADD ./contrib/wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /wildfly && \
    chmod -R ug+rw /wildfly && \
    chmod -R g+rw /opt/s2i/destination

USER 1001

CMD $STI_SCRIPTS_PATH/usage
