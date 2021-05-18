#!/usr/bin/env bash

workdir="${GITHUB_WORKSPACE}/build"
docker_files=$(find "${workdir}/" -name "bareos-*.tar" 2>/dev/null)

# Load Dockerfiles
echo ::group::Load Dockerfile
echo "${docker_files}"
for file in $docker_files ; do
  docker load --input "$file"
done
docker images
echo ::endgroup::

# Test images
echo ::group::Test build tags
while read app version arch path ; do
  ARGS=''
  build_tag=${version}
  re_alpine='^[0-9]+-alpine.*$'
  re_ubuntu='^[0-9]+-ubuntu.*$'

  # Define args and command
  if [[ $version =~ $re_alpine ]] ; then
    build_tag="${version}-${arch}"
    alpine_pkg='bareos'
    [[ "$app" == "webui" ]] && alpine_pkg='bareos-webui'
    CMD="apk list --installed $alpine_pkg" 
  fi
  if [[ $version =~ $re_ubuntu ]] ; then
    CMD="dpkg-query --showformat=\${Version} --show bareos-${app}" 
  fi

  if [[ "$app" == "director" ]] ; then
    ARGS="-e CI_TEST=true"
  fi

  # Check if Dockerfile exist
  if [[ ! -f ${workdir}/bareos-${app}-${build_tag}.tar ]] ; then
    echo ::error::"ERROR-test: $workdir/bareos-${app}-${build_tag}.tar not found"
    continue
  fi

  # Run docker and check version
  img_version=$(docker run -t --rm ${ARGS} \
    ${GITHUB_REPOSITORY}-${app}:${build_tag} \
    ${CMD} | tail -1)

  if [[ $version =~ $re_alpine ]] ; then
    img_version=$(echo "$img_version" |sed -n 's#[a-z-]*\(.*\)#\1#p')
  fi

  short_img_version=$(echo "$img_version" |cut -d'.' -f1)
  short_version=$(echo "$version" |cut -d'-' -f1)

  if [[ $short_img_version -ne $short_version ]] ; then
    echo ::error::"ERROR-test: ${app}:${build_tag} is ${short_img_version}"
    exit 1
  else
    echo "OK: ${app}:${build_tag} is Bareos v${short_img_version}"
  fi

done < "${workdir}/app_build.txt"
echo ::endgroup::

#EOF
