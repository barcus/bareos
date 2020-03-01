#!/bin/sh -l
set -x
ls -l /
ls -l /github
ls -l /github/*
while read app version arch app_path ; do
  docker buildx build \
    --platform ${arch} \
    --output 'type=docker,push-false' \
    --tag barcus/bareos-${app}:${version} \
    ${app_path}
done < homework/app_build.txt
