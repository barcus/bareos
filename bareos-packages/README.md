# bareos-packages — Bareos .deb builder from source

Builds Bareos `.deb` packages from the upstream [bareos/bareos](https://github.com/bareos/bareos)
release branches for (Bareos version, Ubuntu codename) combinations that
`download.bareos.org` does not publish.

## Why

`download.bareos.org/current/` only serves the latest Bareos release (25.x as of 2026).
Versioned repos exist only for Bareos 20 and 21. This builder covers the gap:

| Bareos branch | Ubuntu codename | Published by upstream? |
|---------------|-----------------|------------------------|
| bareos-22     | jammy (22.04)   | no — build from source |
| bareos-23     | jammy (22.04)   | no — build from source |
| bareos-24     | noble (24.04)   | no — build from source |
| bareos-25     | jammy / noble   | yes — `current/`       |

## Build locally

```bash
# Build the jammy builder image
docker build -f Dockerfile.builder.jammy -t bareos-builder:jammy .

# Build Bareos 22 packages for jammy (takes 20–40 min on 4 cores)
mkdir -p ../artifacts
docker run --rm \
  -v "$(pwd)/../artifacts:/artifacts" \
  -e BAREOS_BRANCH=bareos-22 \
  -e UBUNTU_CODENAME=jammy \
  bareos-builder:jammy

# Packages land in: ../artifacts/bareos-22/jammy/*.deb
ls ../artifacts/bareos-22/jammy/
```

Replace `jammy` with `noble` and `bareos-22` with `bareos-24` for the noble variant.

## CI / GitHub Actions

Workflow: `.github/workflows/build-bareos-packages.yml`

- **Manual trigger** (`workflow_dispatch`): builds all three matrix cells.
- **Scheduled**: Sundays at 04:00 UTC to pick up upstream branch fixes.
- **On push** to `bareos-packages/**`: rebuilds on builder file changes.

Artifacts are uploaded (30-day retention) as `debs-<branch>-<codename>`.

## Publishing a GitHub Release

Tag the repo with `pkg/<branch>-<codename>-vN` (e.g. `pkg/bareos-22-jammy-v1`) after
a successful workflow run. The `release` job picks up the artifacts and attaches
`bareos-22-jammy.tar.gz` (etc.) to the release.

```bash
git tag pkg/bareos-22-jammy-v1
git push origin pkg/bareos-22-jammy-v1
```

## Consuming packages in component Dockerfiles

Once a release exists, component Dockerfiles can install from it:

```dockerfile
ARG BAREOS_PKG_RELEASE=pkg/bareos-22-jammy-v1
ARG BAREOS_PKG_REPO=https://github.com/<owner>/<repo>

ADD ${BAREOS_PKG_REPO}/releases/download/${BAREOS_PKG_RELEASE}/bareos-22-jammy.tar.gz /tmp/bareos-pkgs.tar.gz

RUN mkdir -p /tmp/bareos-debs \
 && tar -xzf /tmp/bareos-pkgs.tar.gz -C /tmp/bareos-debs \
 && apt-get update -qq \
 && apt-get install -qq -y --no-install-recommends \
    tzdata gosu postgresql-client \
    /tmp/bareos-debs/bareos-common_*.deb \
    /tmp/bareos-debs/bareos-filedaemon_*.deb \
    /tmp/bareos-debs/bareos-tools_*.deb \
 && rm -rf /tmp/bareos-pkgs.tar.gz /tmp/bareos-debs \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
```

Package names per component (from the bareos debian/ tree):

| Component      | .deb packages to install                                                          |
|----------------|-----------------------------------------------------------------------------------|
| client (fd)    | `bareos-common`, `bareos-filedaemon`, `bareos-tools`                              |
| storage (sd)   | `bareos-common`, `bareos-storage`, `bareos-storage-tape`, `bareos-tools`          |
| director-pgsql | `bareos-common`, `bareos-director`, `bareos-database-common`,                     |
|                | `bareos-database-postgresql`, `bareos-database-tools`                             |
| webui          | `bareos-webui`                                                                    |

Use the `.claude/skills/add-bareos-version` skill to generate component directories once
a release is published — it handles the Dockerfile template and entrypoint wiring.

## Notes

- `bareos-storage-droplet` (S3 plugin) may not appear in all version branches; skip if absent.
- Build time: 20–40 min per matrix cell on a 4-core runner.
- Alpine source-build is deferred; no upstream APKBUILD exists for Bareos.
