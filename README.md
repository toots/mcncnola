# mcncnola

This repository provides a `docker` build and `docker-compose` setup to run a [supercollider](https://supercollider.github.io/) backend connected to a
[Troop](https://github.com/Qirky/Troop) server playing live [FoxDot](https://github.com/Qirky/FoxDot) commands to the local soundcard on a
[Raspberry Pi](https://www.raspberrypi.org/).

It can be used to connect multiple clients and create a laptop orchestra with the Raspberry Pi as the master! The Raspberry Pi can even be turned into
and access point so that it becomes a wifi hub availabe to any location where it is plugged!

## Content

The project provides a single `Dockerfile` which builds a [docker](https://www.docker.com/) image optimized for size with all required parts.

Based on this image, the [docker-compose](https://github.com/docker/compose) files provide:
* A [jack](https://jackaudio.org/) server connected to ALSA
* A supercollider server connected to jack and waiting for commands from troop
* A troop server
* A troop client running inside a `Xvfb` dummy X server
* A (currently unused) [jack-matchmatcher](https://github.com/SpotlightKid/jack-matchmaker) runner, which can be used to automatically connect added jack ports
* An option support for running the wifi access point for the Raspberry Pi

While the project is dedicated to Raspberry Pi, it should be re-usable with other platorms.

## How to build

Build the docker image locally:
```
make build
```

Build the image for Raspberry Pi locally:
```
make build-pi
```

The image tagged is set via the `IMAGE_TAG` makefile variable.

## How to run

First, you need to install docker and docker-compose on the Raspberry Pi
and clone a copy of this repository on it.

To run default supercollider docker-compose elements:
```
make up
```

To run all docker-compose elements, including the wifi access point:
```
make all-up
```

The default wifi AP details are:
* SSID: `mcncnola`
* Password: `nerdzyall`

**TODO**: explain how to make it launch when the Raspberry Pi boots up
