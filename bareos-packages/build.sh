#!/usr/bin/env bash
set -euo pipefail

BAREOS_BRANCH="${BAREOS_BRANCH:?BAREOS_BRANCH env var required (e.g. bareos-22)}"
UBUNTU_CODENAME="${UBUNTU_CODENAME:?UBUNTU_CODENAME env var required (e.g. jammy)}"
ARTIFACTS_DIR="/artifacts/${BAREOS_BRANCH}/${UBUNTU_CODENAME}"

echo "==> Cloning ${BAREOS_BRANCH} ..."
git clone --depth 1 --branch "${BAREOS_BRANCH}" \
    https://github.com/bareos/bareos.git /src

cd /src

echo "==> Installing build dependencies ..."
apt-get update -qq
mk-build-deps \
    --install \
    --remove \
    --tool "apt-get -qq -y --no-install-recommends -o Debug::pkgProblemResolver=yes" \
    debian/control
rm -f /src/bareos-build-deps_*.deb

echo "==> Building packages (nocheck nodoc) ..."
DEB_BUILD_OPTIONS="nocheck nodoc parallel=$(nproc)" \
    dpkg-buildpackage -us -uc -b

echo "==> Collecting artifacts ..."
mkdir -p "${ARTIFACTS_DIR}"
find / -maxdepth 1 -name "bareos*.deb" -exec cp {} "${ARTIFACTS_DIR}/" \;

echo "==> Done. Produced packages:"
ls -lh "${ARTIFACTS_DIR}/"
