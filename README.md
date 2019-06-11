REPOSITORY DEPRECATED
========================================

The s2i Wildfly image is now maintained [here](https://github.com/wildfly/wildfly-s2i).

The Wildfly v8.1 through v16 images can still be built from this repository, but
WF17 onward will come from the new location.


Wildfly - CentOS Docker image
========================================

This repository contains the source for building various versions of
the WildFly application as a reproducible Docker image using
[source-to-image](https://github.com/openshift/source-to-image).
The resulting image can be run using [Docker](http://docker.io).

Versions
---------------
WildFly versions currently provided are:
* WildFly v8.1 (deprecated)
* WildFly v9.0 (deprecated)
* WildFly v10.0 (10.0.0 Final)
* WildFly v10.1
* WildFly v11.0
* WildFly v12.0
* WildFly v13.0
* WildFly v14.0
* WildFly v15.0
* WildFly v16.0

CentOS versions currently provided are:
* CentOS7


Installation
---------------

This image is available on DockerHub.  To download it, run:

```
$ docker pull openshift/wildfly-101-centos7

```

or

```
$ docker pull openshift/wildfly-100-centos7
```

To build a WildFly image from scratch, run:

```
$ git clone https://github.com/openshift-s2i/s2i-wildfly.git
$ cd s2i-wildfly
$ make build VERSION=10.1
```

** Note: by omitting the `VERSION` parameter, the build/test action be performed
on all provided versions of WildFly.**

Usage
---------------------
To build a simple [jee application](https://github.com/openshift/openshift-jee-sample)
using standalone [S2I](https://github.com/openshift/source-to-image) and then run the
resulting image with [Docker](http://docker.io) execute:

```
$ s2i build git://github.com/openshift/openshift-jee-sample openshift/wildfly-101-centos7 wildflytest
$ docker run -p 8080:8080 wildflytest
```

You can also use this as a [S2I Runtime Image](https://github.com/openshift/source-to-image/blob/master/docs/runtime_image.md),
which will produce a final image with source code omitted:

```
$ s2i build git://github.com/openshift/openshift-jee-sample openshift/wildfly-101-centos7 wildflytest --runtime-image openshift/wildfly-101-centos7
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
    $ make test VERSION=10.1
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

          Wildfly modules from the <application source>/modules are copied
          into the wildfly provided modules directory.

        *   **assemble-runtime**

          This script will accept standard Wildfly build artifacts as input, and copy
          them into a separate runtime image for deployment.
          Items in following directories can be accepted as runtime artifacts:

          `deployments/` - these are copied into the wildfly deployments directory

          `configuration/` - these are copied into the wildfly configuration directory

          `provided_modules/` - these are copied into the wildfly provided modules directory.

          See the [S2I runtime image documentation](https://github.com/openshift/source-to-image/blob/master/docs/runtime_image.md)
          for further details.

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
2. Platform version(without dots) - 101
3. Base builder image - centos7

Example: `openshift/wildfly-101-centos7`
Environment variables
---------------------
To set environment variables, you can place them as a key value pair into a `.s2i/environment`
file inside your source code repository.

* MAVEN_ARGS

    Overrides the default arguments passed to maven during the build process

* MAVEN_ARGS_APPEND

    This value will be appended to either the default maven arguments, or the value of MAVEN_ARGS if MAVEN_ARGS is set.

* MAVEN_OPTS

    Contains JVM parameters to maven.  Will be appended to JVM arguments that are calculated by the image
    itself (e.g. heap size), so values provided here will take precedence.

* JAVA_GC_OPTS

    When set to a non-null value, this value will be passed to the JVM instead of the default garbage collection tuning
    values defined by the image.

* CONTAINER_CORE_LIMIT

    When set to a non-null value, the number of parallel garbage collection threads will be set to this value.

* USE_JAVA_DIAGNOSTICS

    When set to a non-null value, various JVM related diagnostics will be turned on such as verbose garbage
    collection tracing.

* AUTO_DEPLOY_EXPLODED

    When set to `true`, Wildfly will automatically deploy exploded war content.  When unset or set to `false`,
    a `.dodeploy` file must be touched to trigger deployment of exploded war content.

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

Known issues
--------------------

**UTF-8 characters not displayed (or displayed as ```?```)**

This can be solved by providing to the JVM the file encoding. Set variable ```MAVEN_OPTS=-Dfile.encoding=UTF-8``` into the build variables


Copyright
--------------------

Released under the Apache License 2.0. See the [LICENSE](LICENSE) file.

