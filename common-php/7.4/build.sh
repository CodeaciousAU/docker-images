#!/bin/bash
set -e

if [ "$1" == "" ]; then
    echo "Usage: build.sh <x.y.z> (where x.y.z is the PHP version for inclusion in the image tag)" >&2
    exit 1
fi

BUILDER=${BUILDER:-multiarch}
IMAGE_NAME="codeacious/common-php"
PHP_VERSION="$1"
IMAGE_VERSION="$PHP_VERSION-$(date +%Y%m%d)"


if ! docker buildx inspect "$BUILDER" >/dev/null 2>&1
then
    docker buildx create --name "$BUILDER" --driver docker-container --bootstrap
fi

docker buildx build --pull "--builder=$BUILDER" "--platform=linux/amd64,linux/arm64" "--tag=$IMAGE_NAME:$IMAGE_VERSION" "--tag=$IMAGE_NAME:7.4" "--tag=$IMAGE_NAME:latest" --push .
