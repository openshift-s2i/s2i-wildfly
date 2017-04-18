Wildfly - CentOS Docker image
========================================

[![Build Status](https://travis-ci.org/openshift-s2i/s2i-wildfly.svg?branch=master)](https://travis-ci.org/openshift-s2i/s2i-wildfly)

This repository contains the source for building various versions of
the WildFly application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
The resulting image can be run using [Docker](http://docker.io).

Versions
---------------
WildFly versions currently provided are:
* WildFly v8.1
* WildFly v9.0
* WildFly v10.0 (10.0.0 Final)
* WildFly v10.1

CentOS versions currently provided are:
* CentOS7


Installation
---------------

This image is available on DockerHub.  To download it, run:

```
$ docker pull openshift/wildfly-81-centos7
```

or

```
$ docker pull openshift/wildfly-90-centos7
```

or

```
$ docker pull openshift/wildfly-100-centos7
```

or

```
$ docker pull openshift/wildfly-101-centos7
```

To build a WildFly image from scratch, run:

```
$ git clone https://github.com/openshift-s2i/s2i-wildfly.git
$ cd s2i-wildfly
$ make build VERSION=8.1
```

** Warning these instructions assume your machine running Docker has the make utilities. This is not the case in Docker Quickstart with MsysGit and the default VM. 

** Note: by omitting the `VERSION` parameter, the build/test action be performed
on all provided versions of WildFly.**

Usage
---------------------
To build a simple [jee application](https://github.com/bparees/openshift-jee-sample)
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

```
$ s2i build git://github.com/bparees/openshift-jee-sample openshift/wildfly-100-centos7 wildflytest
$ docker run -p 8080:8080 wildflytest
```

**Accessing the application:**
```
$ curl 127.0.0.1:8080
```

Test
---------------------
This repository also provides a [S2I](https://github.com/openshift/source-to-image) test framework,
which launches tests to check functionality of a simple WildFly application built on top of the wildfly image.

*  **CentOS based image**

    ```
    $ cd s2i-wildfly
    $ make test VERSION=8.1
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of WildFly.**


Repository organization
------------------------
* **`<WildFly-version>`**

    * **Dockerfile**

        CentOS based Dockerfile

    * **`s2i/bin/`**

        This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

        *   **assemble**

          Is used to restore the build artifacts from the previous build (in case of
          'incremental build'), to install the sources into location from where the
          application will be run and prepare the application for deployment (eg.
          installing maven dependencies, building java code, etc..).

          In addition, the assemble script will distribute artifacts provided in the
          application source project into the Wildfly installation:

          Wildfly configuration files from the <application source>/cfg are copied
          into the wildfly configuration directory.

          Pre-built war files from the <application source>/deployments are moved
          into the wildfly deployment directory.

          Wildfly modules from the <application source>/provided_modules are copied
          into the wildfly modules directory.


        *   **run**

          This script is responsible for running the application, by using the
          Wildfly application server.

        *   **save-artifacts**

          In order to do an *incremental build* (iow. re-use the build artifacts
          from an already built image in a new image), this script is responsible for
          archiving those. In this image, this script will archive the
          maven dependencies and previously built java class files.

    * **`contrib/`**

        This folder contains commonly used modules

        * **`wfbin/`**

            Contains script used to launch wildfly after performing environment variable
            substitution into the standalone.xml configuration file.

        * **`wfcfg/`**

            Contains the default standalone.xml configuration which can be overriden by applications
            that provide a standalone.xml in <application_src>/cfg.

        * **`wfmodules/`**
            Contains commonly used modules such as postgres and mysql database drivers.

    * **`test/`**

        This folder contains the [S2I](https://github.com/openshift/source-to-image)
        test framework with a simple JEE application.

        * **`test-app/`**

            A simple Node.JS echo server used for testing purposes by the [S2I](https://github.com/openshift/source-to-image) test framework.

        * **run**

            This script runs the [S2I](https://github.com/openshift/source-to-image) test framework.

* **`hack/`**

    Folder containing scripts which are responsible for the build and test actions performed by the `Makefile`.

Hot Deploy
------------------------

Hot deploy is enabled by default for all WildFly versions.  
To deploy a new version of your web application without restarting, you will need to either rsync or scp your war/ear/rar/jar file to the /wildfly/standalone/deployments directory within your pod.

Image name structure
------------------------
##### Structure: openshift/1-2-3

1. Platform name (lowercase) - wildfly
2. Platform version(without dots) - 81
3. Base builder image - centos7

Example: `openshift/wildfly-81-centos7`
Environment variables
---------------------
To set environment variables, you can place them as a key value pair into a `.sti/environment`
file inside your source code repository.

* MAVEN_ARGS

    Overrides the default arguments passed to maven durin the build process

* MAVEN_ARGS_APPEND

    This value will be appended to either the default maven arguments, or the value of MAVEN_ARGS if MAVEN_ARGS is set.

* MYSQL_DATABASE

    If set, WildFly will attempt to define a MySQL datasource based on the assumption you have an OpenShift service named "mysql" defined.
    It will attempt to reference the following environment variables which are automatically defined if the "mysql" service exists:
    MYSQL_SERVICE_PORT
    MYSQL_SERVICE_HOST
    MYSQL_PASSWORD
    MYSQL_USER

* POSTGRESQL_DATABASE

    If set, WildFly will attempt to define a PostgreSQL datasource based on the assumption you have an OpenShift service named "postgresql" defined.
    It will attempt to reference the following environment variables which are automatically defined if the "postgresql" service exists:
    POSTGRESQL_SERVICE_PORT
    POSTGRESQL_SERVICE_HOST
    POSTGRESQL_PASSWORD
    POSTGRESQL_USER


Copyright
--------------------

Released under the Apache License 2.0. See the [LICENSE](LICENSE) file.
