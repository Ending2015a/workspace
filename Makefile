TAG ?= $(USER)
BASE_IMAGE ?= nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04
WORKSPACE_DOCKERFILE ?= docker/workspace.Dockerfile
WORKSPACE_IMAGE ?= workspace
WORKDIR ?= /workspace
SHM_SIZE ?= 16G

EXTRA_ARGS ?=
EXTRA_ARGS := $(EXTRA_ARGS) --network host
EXTRA_ARGS := $(if $(SHM_SIZE), $(EXTRA_ARGS) --shm-size $(SHM_SIZE), $(EXTRA_ARGS))
EXTRA_ARGS := $(if $(DISPLAY), $(EXTRA_ARGS) -e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix, $(EXTRA_ARGS))
COMMAND ?= /bin/bash

.PHONY: build
build:
	docker build . -f $(WORKSPACE_DOCKERFILE) -t $(WORKSPACE_IMAGE):$(TAG) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg WORKDIR=$(WORKDIR)

.PHONY: run
run:
	xhost +
	docker run --gpus all -it --rm \
		-v $(realpath ./):$(WORKDIR) \
		$(EXTRA_ARGS) \
		$(WORKSPACE_IMAGE):$(TAG) \
		$(COMMAND)

.PHONY: dev
dev:
	@pip install pre-commit hatch
	-pre-commit install --hook-type pre-commit

.PHONY: lint
lint: dev
	pre-commit run
