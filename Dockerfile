# syntax=docker/dockerfile:1
ARG JUST_VERSION

# Stage 1: Download the just binary for the target architecture.
# FROM --platform=$BUILDPLATFORM ensures this stage runs natively (no QEMU).
FROM --platform=$BUILDPLATFORM alpine:3.21 AS downloader

ARG JUST_VERSION
ARG TARGETARCH

RUN apk add --no-cache wget tar

RUN set -eux; \
    case "$TARGETARCH" in \
        amd64) TARGET="x86_64-unknown-linux-musl" ;; \
        arm64) TARGET="aarch64-unknown-linux-musl" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    wget -qO /tmp/just.tar.gz \
        "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${TARGET}.tar.gz"; \
    tar -xzf /tmp/just.tar.gz -C /tmp just; \
    chmod +x /tmp/just

FROM scratch

LABEL org.opencontainers.image.source="https://github.com/lukewiwa/just-container"

COPY --from=downloader /tmp/just /usr/local/bin/just

ENTRYPOINT ["/usr/local/bin/just"]
