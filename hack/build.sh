#!/bin/bash -e
# This script is used to build and test the OpenShift Docker images.
#
# Name of resulting image will be: 'DOCKER_REPO/BASE_IMAGE_NAME-VERSION-OS'.
# Default docker repo is openshift.
#
# BASE_IMAGE_NAME - Usually name of the main component within container.
# OS - Specifies distribution - "rhel7" or "centos7"
# VERSION - Specifies the image version - (must match with subdirectory in repo)
# TEST_MODE - If set, build a candidate image and test it
# TAG_ON_SUCCESS - If set, tested image will be re-tagged as a non-candidate
#       image, if the tests pass.
# VERSIONS - Must be set to a list with possible versions (subdirectories)
# OPENSHIFT_NAMESPACES - Which of available versions (subdirectories) should be
#       put into openshift/ namespace.

OS=${1-$OS}
VERSION=${2-$VERSION}

# we don't build/test a rhel version of wildfly.
if [ ${OS} != "centos7" ]; then
  exit 0
fi

DOCKERFILE_PATH=""

test -z "$BASE_IMAGE_NAME" && {
  BASE_DIR_NAME=$(echo $(basename `pwd`) | sed -e 's/-[0-9]*$//g')
  BASE_IMAGE_NAME="${BASE_DIR_NAME#s2i-}"
}

NAMESPACE="${DOCKER_REPO:-openshift}/"

# Cleanup the temporary Dockerfile created by docker build with version
trap "rm -f ${DOCKERFILE_PATH}.version" SIGINT SIGQUIT EXIT

# Perform docker build but append the LABEL with GIT commit id at the end
function docker_build_with_version {
  local dockerfile="$1"
  # Use perl here to make this compatible with OSX
  DOCKERFILE_PATH=$(perl -MCwd -e 'print Cwd::abs_path shift' $dockerfile)
  cp ${DOCKERFILE_PATH} "${DOCKERFILE_PATH}.version"
  git_version=$(git rev-parse --short HEAD)
  echo "LABEL io.openshift.builder-version=\"${git_version}\"" >> "${dockerfile}.version"
  docker build -t ${IMAGE_NAME} -f "${dockerfile}.version" .
  rm -f "${DOCKERFILE_PATH}.version"
}

# Versions are stored in subdirectories. You can specify VERSION variable
# to build just one single version. By default we build all versions
dirs=${VERSION:-$VERSIONS}

for dir in ${dirs}; do
  case " $OPENSHIFT_NAMESPACES " in
    *\ ${dir}\ *) ;;
    *)
      if [ "${OS}" == "centos7" ]; then
        NAMESPACE="centos/"
      else
        NAMESPACE="rhscl/"
      fi
  esac

  IMAGE_NAME="${NAMESPACE}${BASE_IMAGE_NAME}-${dir//./}-${OS}"

  if [[ ! -z "${TEST_MODE:-}" ]]; then
    IMAGE_NAME+="-candidate"
  fi

  echo "-> Building ${IMAGE_NAME} ..."

  pushd ${dir} > /dev/null
#  if [ "$OS" == "rhel7" -o "$OS" == "rhel7-candidate" ]; then
#    docker_build_with_version Dockerfile.rhel7
#  else
    docker_build_with_version Dockerfile
#  fi

  if [[ ! -z "${TEST_MODE:-}" ]]; then
    IMAGE_NAME=${IMAGE_NAME} test/run

    if [[ $? -eq 0 ]] && [[ "${TAG_ON_SUCCESS}" == "true" ]]; then
      echo "-> Re-tagging ${IMAGE_NAME} image to ${IMAGE_NAME%"-candidate"}"
      docker tag $IMAGE_NAME ${IMAGE_NAME%"-candidate"}
    fi
  fi

  popd > /dev/null
done
