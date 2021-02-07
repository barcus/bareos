#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Load buildx binary
mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
cp "${workdir}/docker-buildx" ~/.docker/cli-plugins/
chmod a+x ~/.docker/cli-plugins/docker-buildx

# Create build context and build
docker buildx create --use
while read app version arch app_path ; do
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
    --output "type=oci,dest=${workdir}/bareos-${app}-${tag}.tar" \
    --tag "${GITHUB_REPOSITORY}-${app}:${tag}" \
    --force-rm \
    "${app_path}"

  if [[ $? -ne 0 ]] ; then
    echo "::error:: ERROR: build failed ${GITHUB_REPOSITORY}-${app}:${tag} in ${app_path}"
  fi

done < "${workdir}/app_build.txt"

# Clean builder
docker buildx rm

chmod 755 "${workdir}"/bareos-*.tar

#EOF
