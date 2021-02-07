#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Load buildx binary
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
cp "${workdir}/docker-buildx" ~/.docker/cli-plugins/
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Run Qemu
docker run --rm --privileged tonistiigi/binfmt --install all

# Install git
apk add --no-cache git

# Create build context and build
while read app version arch app_path ; do
  docker buildx create --driver docker-container --use
  tag="${version}"
  re='^[0-9]+-alpine.*$'
  if [[ $version =~ $re ]] ; then
    tag="${version}-${arch}"
  fi

  # Build with buildx
  docker buildx build \
    --platform "linux/${arch}" \
    --build-arg VERSION=$(echo "$version" |cut -d'-' -f1) \
    --build-arg VCS_REF=$(git rev-parse --short HEAD) \
    --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
    --build-arg NAME="${GITHUB_REPOSITORY}-${app}" \
    --output 'type=docker,push=false' \
    --tag "${GITHUB_REPOSITORY}-${app}:${tag}" \
    --force-rm
    "${app_path}"

  if [[ $? -ne 0 ]] ; then
    echo "::warning:: ERROR: build failed ${GITHUB_REPOSITORY}-${app}:${tag} in ${app_path}"
  fi

  # Save image to tar file
  docker save \
    --output "${workdir}/bareos-${app}-${tag}.tar" \
    "${GITHUB_REPOSITORY}-${app}:${tag}"

  # Clean builder
  docker buildx rm
done < "${workdir}/app_build.txt"

chmod 755 "${workdir}"/bareos-*.tar

#EOF
