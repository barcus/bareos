# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of Docker images for running [Bareos](https://www.bareos.org) (backup software) in containers. It does not contain application source code — it contains Dockerfiles, entrypoint shell scripts, and docker-compose files for deploying Bareos components.

## Components

Each component lives in its own directory with per-version subdirectories (e.g. `24-alpine`, `24-ubuntu`):

- **`director-pgsql/`** — Bareos Director (orchestrator) backed by PostgreSQL
- **`director-mysql/`** — Bareos Director backed by MySQL (deprecated in Bareos 21+)
- **`storage/`** — Bareos Storage Daemon
- **`client/`** — Bareos File Daemon (client)
- **`webui/`** — Bareos Web UI (PHP-FPM based)
- **`api/`** — Bareos REST API (Python/FastAPI, `bareos-restapi` pip package)
- **`bareos-db-migration/`** — MySQL → PostgreSQL migration tooling

Each version directory contains: `Dockerfile`, `docker-entrypoint.sh`, and sometimes `webhook-notify`.

## Building Images

```bash
# Build a specific component/version
docker build -t director-pgsql:24-ubuntu director-pgsql/24-ubuntu
docker build -t storage:24-ubuntu storage/24-ubuntu
docker build -t client:24-ubuntu client/24-ubuntu
docker build -t webui:24-ubuntu webui/24-ubuntu
docker build -t api:24-alpine api/24-alpine
```

## Running Locally

```bash
# Copy and configure env
cp .env.dist .env
# Edit .env with real passwords

# Start the stack (default symlink points to alpine-pgsql)
docker compose up -d

# Or specify a compose file explicitly
docker compose -f docker-compose-alpine-pgsql.yml up -d

# Enable DB init on first run (edit the compose file first)
# Set DB_INIT=true in the compose file before first launch
```

Available compose files: `docker-compose-alpine-pgsql.yml`, `docker-compose-alpine-mysql.yml`, `docker-compose-alpine-mysql-v2.yml`, `docker-compose-ubuntu-mysql.yml`, `docker-compose-ubuntu-pgsql.yml`. The `docker-compose.yml` symlink points to the alpine-pgsql variant.

## Accessing Services

```bash
# Bareos CLI console
docker exec -it bareos_bareos-dir_1 bconsole

# WebUI: http://localhost:8080 (admin / <BAREOS_WEBUI_PASSWORD>)
# REST API docs: http://localhost:8000/docs
# Prometheus metrics: http://localhost:9625/metrics
```

## How Entrypoint Scripts Work

The `docker-entrypoint.sh` in each component performs first-run configuration:

- Uses a sentinel file (`/etc/bareos/bareos-config.control`) to detect first run
- Unpacks bundled default config (`/bareos-dir.tgz`) and applies `sed` substitutions for env vars (DB credentials, host names, passwords)
- Director: supports `DB_INIT=true` to create PostgreSQL user/db and run Bareos schema scripts, and `DB_UPDATE=true` to run schema migrations
- Webhook notifications (Slack/Telegram) replace email notifications when `WEBHOOK_NOTIFICATION=true`

## Key Environment Variables

See `.env.dist` for all required variables. The most important ones for the Director:

| Variable | Purpose |
|---|---|
| `DB_INIT` | Set `true` on first run to create DB schema |
| `DB_UPDATE` | Set `true` to run DB migrations after upgrade |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Catalog DB connection |
| `DB_ADMIN_USER`, `DB_ADMIN_PASSWORD` | Used only for DB initialization |
| `BAREOS_SD_PASSWORD`, `BAREOS_FD_PASSWORD`, `BAREOS_WEBUI_PASSWORD` | Shared secrets between components |
| `SMTP_HOST`, `ADMIN_MAIL` | Mail reporting |
| `WEBHOOK_NOTIFICATION`, `WEBHOOK_TYPE`, `WEBHOOK_URL` | Slack/Telegram notifications |

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- `ci-director.yml`, `ci-client.yml`, `ci-storage.yml`, `ci-webui.yml`, `ci-api.yml` — build and push images; triggered on changes to the respective component directories
- `run-compose.yml` — integration test: spins up each compose variant and runs `bconsole` to verify the stack is healthy (runs weekly on Sundays and on compose file changes)
- `build-bareos-packages.yml` — builds `.deb` packages from the bareos source repo for versions not available on `download.bareos.org`; see `bareos-packages/README.md`
- `test-n-lint.yml` — linting
- `push-readme.yml` — syncs README to Docker Hub

The CI uses reusable composite actions in `.github/actions/` (prepare, build, push, test).

## Version Support

- Alpine images support `linux/amd64` and `linux/arm64/v8`
- Current active versions: 22 (Ubuntu and Alpine), 24 (Ubuntu)
- MySQL backend was dropped in Bareos 21+; `director-mysql/` only goes up to version 20

### Upstream package availability

`download.bareos.org` only publishes versioned repos for Bareos 20 and 21. For 22+:

| Bareos version | Ubuntu                          | Alpine            |
|----------------|---------------------------------|-------------------|
| 20             | versioned apt repo              | Alpine 3.15       |
| 21             | versioned apt repo              | Alpine 3.17       |
| 22             | `current/` (serves 25.x today) | Alpine 3.18       |
| 23             | not published upstream          | not published     |
| 24             | not published upstream          | not published     |
| 25             | `current/` (latest)            | not published     |

Use `bareos-packages/` to build `.deb` packages from source for versions 22–24.
Once packages are published as GitHub Releases, use the `.claude/skills/add-bareos-version`
skill to generate new component directories that install from those artifacts.
