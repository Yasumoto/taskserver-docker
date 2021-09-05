# Taskserver Docker Images

Based off https://github.com/yhaenggi/taskserver-docker

This image is intended to run on amd64

## Usage ##

To explore around the image:

    sudo docker run --rm -it -v (pwd):(pwd) --entrypoint=fish yasumoto7/taskserver:v1.1.0

## Build ##

    ./build.sh

## Tags ##

    Note that the tag should match upstream's tag with our changes on top.

   * v1.1.0
