.PHONY: submodules all

BUILDX :=
PLATFORM :=
IMAGE_TAG := mcncnola/mcncnola

build: submodules
	docker $(BUILDX) build $(PLATFORM) -t $(IMAGE_TAG) .

submodules:
	git submodule init
	git submodule update --init --recursive

build-pi:
	$(MAKE) BUILDX=buildx PLATFORM="--platform linux/arm/v6" IMAGE_TAG=$(IMAGE_TAG) 

all-up::
	wpa_cli terminate
	docker-compose -f docker-compose.yml -f ap.yml up

up:
	docker-compose up
