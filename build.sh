#!/bin/sh
VERSION="v1.1.0"

docker build yasumoto/taskserver -t ${VERSION} --build-arg VERSION=${VERSION} .

docker push yasumoto/taskserver:${VERSION}
