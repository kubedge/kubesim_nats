
# Image URL to use all building/pushing image targets
SUB_COMPONENT        ?= kubesim_nats_sub
PUB_COMPONENT        ?= kubesim_nats_pub
VERSION_V1           ?= 0.2.24
SUB_DHUBREPO         ?= kubedge1/${SUB_COMPONENT}
SUB_DHUBREPO_DEV     ?= kubedge1/${SUB_COMPONENT}-dev
SUB_DHUBREPO_AMD64   ?= kubedge1/${SUB_COMPONENT}-amd64
SUB_DHUBREPO_ARM32V7 ?= kubedge1/${SUB_COMPONENT}-arm32v7
SUB_DHUBREPO_ARM64V8 ?= kubedge1/${SUB_COMPONENT}-arm64v8
PUB_DHUBREPO         ?= kubedge1/${PUB_COMPONENT}
PUB_DHUBREPO_DEV     ?= kubedge1/${PUB_COMPONENT}-dev
PUB_DHUBREPO_AMD64   ?= kubedge1/${PUB_COMPONENT}-amd64
PUB_DHUBREPO_ARM32V7 ?= kubedge1/${PUB_COMPONENT}-arm32v7
PUB_DHUBREPO_ARM64V8 ?= kubedge1/${PUB_COMPONENT}-arm64v8
DOCKER_NAMESPACE     ?= kubedge1
SUB_IMG              ?= ${SUB_DHUBREPO}:v${VERSION_V1}
SUB_IMG_DEV          ?= ${SUB_DHUBREPO_DEV}:v${VERSION_V1}
SUB_IMG_AMD64        ?= ${SUB_DHUBREPO_AMD64}:v${VERSION_V1}
SUB_IMG_ARM32V7      ?= ${SUB_DHUBREPO_ARM32V7}:v${VERSION_V1}
SUB_IMG_ARM64V8      ?= ${SUB_DHUBREPO_ARM64V8}:v${VERSION_V1}
PUB_IMG              ?= ${PUB_DHUBREPO}:v${VERSION_V1}
PUB_IMG_DEV          ?= ${PUB_DHUBREPO_DEV}:v${VERSION_V1}
PUB_IMG_AMD64        ?= ${PUB_DHUBREPO_AMD64}:v${VERSION_V1}
PUB_IMG_ARM32V7      ?= ${PUB_DHUBREPO_ARM32V7}:v${VERSION_V1}
PUB_IMG_ARM64V8      ?= ${PUB_DHUBREPO_ARM64V8}:v${VERSION_V1}
K8S_NAMESPACE        ?= default

all: docker-build

setup:
ifndef GOPATH
	$(error GOPATH not defined, please define GOPATH. Run "go help gopath" to learn more about GOPATH)
endif
	# dep ensure

clean:
	rm -fr vendor
	rm -fr cover.out
	rm -fr build/_output
	rm -fr config/crds
	rm -fr go.sum

# Run go fmt against code
fmt: setup
	go fmt ./kubesim_nats_sub/... ./kubesim_nats_pub/...

# Run go vet against code
vet-v1: fmt
	go vet -composites=false -tags=v1 ./kubesim_nats_sub/... ./kubesim_nats_pub/...

# Build the docker image
docker-build: fmt vet-v1 docker-build-dev-sub docker-build-amd64-sub docker-build-arm32v7-sub docker-build-arm64v8-sub docker-build-dev-pub docker-build-amd64-pub docker-build-arm32v7-pub docker-build-arm64v8-pub

docker-build-dev-sub:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/kubesim-nats-sub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_sub/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.kubesim-nats-sub -t ${SUB_IMG_DEV}
	docker tag ${SUB_IMG_DEV} ${SUB_DHUBREPO_DEV}:latest

docker-build-amd64-sub:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/kubesim-nats-sub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_sub/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.amd64.kubesim-nats-sub -t ${SUB_IMG_AMD64}
	docker tag ${SUB_IMG_AMD64} ${SUB_DHUBREPO_AMD64}:latest

docker-build-arm32v7-sub:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/kubesim-nats-sub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_sub/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.arm32v7.kubesim-nats-sub -t ${SUB_IMG_ARM32V7}
	docker tag ${SUB_IMG_ARM32V7} ${SUB_DHUBREPO_ARM32V7}:latest

docker-build-arm64v8-sub:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/kubesim-nats-sub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_sub/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.arm64v8.kubesim-nats-sub -t ${SUB_IMG_ARM64V8}
	docker tag ${SUB_IMG_ARM64V8} ${SUB_DHUBREPO_ARM64V8}:latest

docker-build-dev-pub:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/bin/kubesim-nats-pub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_pub/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.kubesim-nats-pub -t ${PUB_IMG_DEV}
	docker tag ${PUB_IMG_DEV} ${PUB_DHUBREPO_DEV}:latest

docker-build-amd64-pub:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o build/_output/amd64/kubesim-nats-pub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_pub/...
	docker buildx build --platform=linux/amd64 . -f build/Dockerfile.amd64.kubesim-nats-pub -t ${PUB_IMG_AMD64}
	docker tag ${PUB_IMG_AMD64} ${PUB_DHUBREPO_AMD64}:latest

docker-build-arm32v7-pub:
	GOOS=linux GOARM=7 GOARCH=arm CGO_ENABLED=0 go build -o build/_output/arm32v7/kubesim-nats-pub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_pub/...
	docker buildx build --platform=linux/arm/v7 . -f build/Dockerfile.arm32v7.kubesim-nats-pub -t ${PUB_IMG_ARM32V7}
	docker tag ${PUB_IMG_ARM32V7} ${PUB_DHUBREPO_ARM32V7}:latest

docker-build-arm64v8-pub:
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -o build/_output/arm64v8/kubesim-nats-pub -gcflags all=-trimpath=${GOPATH} -asmflags all=-trimpath=${GOPATH} -tags=v1 ./kubesim_nats_pub/...
	docker buildx build --platform=linux/arm64 . -f build/Dockerfile.arm64v8.kubesim-nats-pub -t ${PUB_IMG_ARM64V8}
	docker tag ${PUB_IMG_ARM64V8} ${PUB_DHUBREPO_ARM64V8}:latest


# Push the docker image
docker-push: docker-push-dev docker-push-amd64 docker-push-arm32v7 docker-push-arm64v8

docker-push-dev:
	docker push ${PUB_IMG_DEV}
	docker push ${SUB_IMG_DEV}

docker-push-amd64:
	docker push ${PUB_IMG_AMD64}
	docker push ${SUB_IMG_AMD64}

docker-push-arm32v7:
	docker push ${PUB_IMG_ARM32V7}
	docker push ${SUB_IMG_ARM32V7}

docker-push-arm64v8:
	docker push ${PUB_IMG_ARM64V8}
	docker push ${SUB_IMG_ARM64V8}

# Build the docker image for cross-plaform support
CONTAINER_TOOL ?= docker
SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

PLATFORMS ?= linux/arm64,linux/amd64,linux/arm/v7
.PHONY: docker-sub-buildx
docker-sub-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.buildkit.kubesim-nats-sub > Dockerfile.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${SUB_IMG} --tag ${SUB_DHUBREPO}:latest -f Dockerfile.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.cross

.PHONY: docker-pub-buildx
docker-pub-buildx: ## Build and push docker image for the manager for cross-platform support
	# copy existing Dockerfile and insert --platform=${BUILDPLATFORM} into Dockerfile.cross, and preserve the original Dockerfile
	sed -e '1 s/\(^FROM\)/FROM --platform=\$$\{BUILDPLATFORM\}/; t' -e ' 1,// s//FROM --platform=\$$\{BUILDPLATFORM\}/' build/Dockerfile.buildkit.kubesim-nats-pub > Dockerfile.cross
	- $(CONTAINER_TOOL) buildx create --name project-v3-builder
	$(CONTAINER_TOOL) buildx use project-v3-builder
	- $(CONTAINER_TOOL) buildx build --push --platform=$(PLATFORMS) --tag ${PUB_IMG} --tag ${PUB_DHUBREPO}:latest -f Dockerfile.cross .
	- $(CONTAINER_TOOL) buildx rm project-v3-builder
	rm Dockerfile.cross

# Cross compilation
docker-buildx: fmt vet-v1 docker-sub-buildx docker-pub-buildx
