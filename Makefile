# Variables
REGISTRY:=ghcr.io/phillong97254
PROJECT_NAME:=go-tools
TAG:=v1.0.0
IMAGE:=$(REGISTRY)/$(PROJECT_NAME)
DOCKER_BIN := docker

.PHONY: build check docker-login push release

# Build image local: ghcr.io/phillong97254/go-tools:<TAG>
build:
	@$(DOCKER_BIN) build --rm --force-rm -t $(IMAGE):$(TAG) .
	-@$(DOCKER_BIN) image prune -f --filter label=stage=Builder

# In version các công cụ trong image
check:
	@$(DOCKER_BIN) run --rm $(IMAGE):$(TAG) sh -c 'go version; migrate -version; buf --version; protoc-gen-go --version; protoc-gen-go-grpc --version; psql --version'

# Đăng nhập GitHub Container Registry (username GitHub + token có quyền write:packages)
docker-login:
	@$(DOCKER_BIN) login ghcr.io

push: build
	@$(DOCKER_BIN) push $(IMAGE):$(TAG)

# make release TAG=v1.1.0 -> tag git + push (các service build image từ git tag này)
release:
	git tag $(TAG)
	git push origin $(TAG)
