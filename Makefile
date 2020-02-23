BUILDX_VER=v0.3.1
CI_NAME?=local
VERSION?=latest

install:
	mkdir -vp ~/.docker/cli-plugins/ ~/dockercache
	curl --silent -L "https://github.com/docker/buildx/releases/download/${BUILDX_VER}/buildx-${BUILDX_VER}.linux-amd64" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

prepare: install
	docker context create mycontext
	docker buildx create mycontext --use
	#docker buildx inspect --bootstrap

build-push:
	docker buildx build --push\
		--build-arg CI_NAME=${CI_NAME} \
		--platform linux/arm64,linux/amd64 \
		-t barcus/baros-client-test .
