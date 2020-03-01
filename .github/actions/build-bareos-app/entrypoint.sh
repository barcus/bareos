#!/bin/sh -l
set -x
echo $env
while read app version arch app_path ; do
  docker buildx build \
    --platform ${arch} \
    --output 'type=docker,push-false' \
    --tag barcus/bareos-${app}:${version} \
    ${app_path}
done < $(grep ${bareos_app} homework/app_build.txt)
