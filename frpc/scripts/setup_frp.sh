#!/bin/sh
set -e

TARGETARCH="${1:-amd64}"

case "${TARGETARCH}" in
    amd64)
        FRP_ARCH="amd64"
        ;;
    arm64|aarch64)
        FRP_ARCH="arm64"
        ;;
    arm|armv7)
        FRP_ARCH="arm"
        ;;
    *)
        echo "Unsupported architecture: ${TARGETARCH}"
        exit 1
        ;;
esac

echo "${FRP_ARCH}"

