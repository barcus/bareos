BUILDX_VER=v0.3.0
CI_NAME?=local
VERSION?=latest

install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

prepare: install
	docker buildx create --use

prepare-old: install
	docker context create old-style
	docker buildx create old-style --use

build-push:
	docker buildx build --push \
		--build-arg CI_NAME=${CI_NAME} \
		--platform linux/arm/v7,linux/arm64/v8,linux/386,linux/amd64 \
		-t barcus/baros-client:19-linux-arm .
