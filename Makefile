# Variables
# Docker Hub: hub.docker.com/r/phillong2504/go-tools
REGISTRY:=phillong2504
PROJECT_NAME:=go-tools
TAG:=v1.0.0
IMAGE:=$(REGISTRY)/$(PROJECT_NAME)
DOCKER_BIN := docker

.PHONY: build check docker-login push release

# Build image local: phillong2504/go-tools:<TAG>
build:
	@$(DOCKER_BIN) build --rm --force-rm -t $(IMAGE):$(TAG) .
	-@$(DOCKER_BIN) image prune -f --filter label=stage=Builder

# In version các công cụ trong image
check:
	@$(DOCKER_BIN) run --rm $(IMAGE):$(TAG) sh -c 'go version; migrate -version; buf --version; protoc-gen-go --version; protoc-gen-go-grpc --version; psql --version'

# Đăng nhập Docker Hub (username + Personal Access Token quyền Read & Write)
docker-login:
	@$(DOCKER_BIN) login -u $(REGISTRY)

push: build
	@$(DOCKER_BIN) push $(IMAGE):$(TAG)
	@$(DOCKER_BIN) tag $(IMAGE):$(TAG) $(IMAGE):latest
	@$(DOCKER_BIN) push $(IMAGE):latest

# make release TAG=v1.1.0 -> tag git + push (các service build image từ git tag này)
release:
	git tag $(TAG)
	git push origin $(TAG)
