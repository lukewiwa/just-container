# just-container

[![Build and Publish](https://github.com/lukewiwa/just-container/actions/workflows/build.yml/badge.svg)](https://github.com/lukewiwa/just-container/actions/workflows/build.yml)

Minimal Docker images containing only the [`just`](https://github.com/casey/just) command runner binary, published to `ghcr.io`. Designed as a build artifact source for multi-stage Dockerfiles.

---

## Usage

Copy the `just` binary into your Docker image from this image using `COPY --from=`:

```dockerfile
# Pinned version (recommended for reproducibility)
COPY --from=ghcr.io/lukewiwa/just-container:1.40.0 /usr/local/bin/just /usr/local/bin/just

# Latest version
COPY --from=ghcr.io/lukewiwa/just-container:latest /usr/local/bin/just /usr/local/bin/just
```

Full example:

```dockerfile
FROM --platform=$BUILDPLATFORM ghcr.io/lukewiwa/just-container:1.40.0 AS just-container

FROM debian:bookworm-slim
COPY --from=just-container /usr/local/bin/just /usr/local/bin/just
RUN just --version
```

---

## Platforms & Tags

| Tag | Platforms |
|-----|-----------|
| `latest` | `linux/amd64`, `linux/arm64` |
| `<version>` (e.g. `1.40.0`) | `linux/amd64`, `linux/arm64` |

The version tag matches the upstream `just` release tag exactly (e.g. `1.40.0`).

---

## How It Works

1. **Monthly schedule** — A GitHub Actions workflow runs on the 1st of each month at 06:00 UTC.
2. **Version check** — The workflow fetches the latest `just` release tag from the GitHub API.
3. **Existence check** — If the image for that version already exists in `ghcr.io`, the build is skipped.
4. **Multi-platform build** — Docker Buildx builds for `linux/amd64` and `linux/arm64` in a single manifest. The download stage runs natively on the host (no QEMU needed for the download itself).
5. **Scratch image** — The final image is based on `scratch` and contains only the `just` binary at `/usr/local/bin/just`.

---

## Manual Trigger

To trigger a build immediately, go to **Actions → Build and Publish just-container → Run workflow**.

Check **Force rebuild** to rebuild and re-push even if the image already exists in the registry.

---

## Setup

No secrets or configuration required. The workflow uses the automatically provided `GITHUB_TOKEN` for both reading and pushing to `ghcr.io`.

The `org.opencontainers.image.source` label in the Dockerfile links the published package to this repository automatically.
