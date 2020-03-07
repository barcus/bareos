#!/usr/bin/env bash

set -x
cat /github/workspace/README.md

ls -l /github/workspace/
# Update Docker Hub overview
docker run -v $PWD:/workspace \
  -e DOCKERHUB_USERNAME=barcus \
  -e DOCKERHUB_PASSWORD=$INPUT_DOCKER_PASS \
  -e DOCKERHUB_REPOSITORY="${GITHUB_REPOSITORY}-${INPUT_BAREOS_APP}" \
  -e README_FILEPATH='/workspace/README.md' \
  peterevans/dockerhub-description:2.1.0

#EOF
