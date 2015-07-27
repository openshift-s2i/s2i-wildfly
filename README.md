Wildfly - CentOS Docker image
========================================

This repository contains the source for building various versions of
the WildFly application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
The resulting image can be run using [Docker](http://docker.io).

Versions
---------------
WildFly versions currently provided are:
* WildFly v8.1

CentOS versions currently provided are:
* CentOS7


Installation
---------------

This image is available on DockerHub.  To download it, run:

```
$ docker pull openshift/wildfly-81-centos7
```

To build a WildFly image from scratch, run:

```
$ git clone https://github.com/openshift/sti-wildfly.git
$ cd sti-wildfly
$ make build VERSION=8.1
```

** Note: by omitting the `VERSION` parameter, the build/test action be performed 
on all provided versions of WildFly.  Since we are currently only providing 
version `8.1`, you can omit this parameter.**

Usage
---------------------
To build a simple [jee application](https://github.com/bparees/openshift-jee-sample)
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

```
$ sti build git://github.com/bparees/openshift-jee-sample openshift/wildfly-81-centos wildflytest
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
    $ cd sti-wildfly
    $ make test VERSION=8.1
    ```

**Notice: By omitting the `VERSION` parameter, the build/test action will be performed
on all provided versions of WildFly. Since we are currently providing only version `8.1`
you can omit this parameter.**


Repository organization
------------------------
* **`<WildFly-version>`**

    * **Dockerfile**

        CentOS based Dockerfile    

    * **`.sti/bin/`**

        This folder contains scripts that are run by [S2I](https://github.com/openshift/source-to-image):

        *   **assemble**

          Is used to restore the build artifacts from the previous built (in case of
          'incremental build'), to install the sources into location from where the
          application will be run and prepare the application for deployment (eg.
          installing maven dependencies, building java code, etc..).

          In addition, the assemble script will copy artifacts provided in the
          application source project into the Wildfly installation:

          Wildfly configuration files from the <application source>/cfg are copied
          into the wildfly configuration directory.

          Pre-built war files from the <application source>/deployments are copied
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

Released under the Apache License 2.0. See the [LICENSE](https://github.com/openshift/sti-wildfly/blob/master/LICENSE) file.
