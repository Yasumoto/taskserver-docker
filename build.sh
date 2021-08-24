#!/bin/sh

set -eux

VERSION="v1.1.0"

sudo docker build -t "yasumoto7/taskserver:${VERSION}" --build-arg VERSION="${VERSION}" .

sudo docker push "yasumoto7/taskserver:${VERSION}"
