# Aurora Yoga Duet 7 - Customized for Lenovo Yoga Duet 7 13IML05 (82AS)
# Base: Aurora (ghcr.io/ublue-os/aurora)
# Maintainer: Daniel Bodnar <daniel.bodnar@gmail.com>

ARG BASE_IMAGE="ghcr.io/ublue-os/aurora"
ARG BASE_TAG="latest"
ARG FEDORA_MAJOR_VERSION="42"

FROM scratch AS ctx
COPY /system_files /system_files
COPY /build_files /build_files
COPY /lenovo-firmware /lenovo-firmware

## aurora-yoga-duet image section
FROM ${BASE_IMAGE}:${BASE_TAG} AS yoga-duet

ARG FEDORA_MAJOR_VERSION="42"
ARG IMAGE_NAME="aurora-yoga-duet"
ARG IMAGE_VENDOR="danielbodnar"
ARG SHA_HEAD_SHORT="deadbeef"
ARG VERSION=""

# Build, cleanup, lint
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build_files/shared/build.sh

RUN bootc container lint
