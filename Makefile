# Variables are documented in hack/build.sh.
BASE_IMAGE_NAME = wildfly
VERSIONS = 8.1 9.0 10.0 10.1
OPENSHIFT_NAMESPACES = 8.1 9.0 10.0 10.1

# Include common Makefile code.
include hack/common.mk
