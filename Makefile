# Variables are documented in hack/build.sh.
BASE_IMAGE_NAME = wildfly
VERSIONS = 8.1 9.0 10.0
OPENSHIFT_NAMESPACES = 8.1 9.0 10.0

# Include common Makefile code.
include hack/common.mk
