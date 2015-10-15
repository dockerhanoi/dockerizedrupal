PRIVATE_REGISTRY_URL=registry.olbius.lan:5000

DOCKER_IMAGE=tranhuucuong91/drupal
VERSION=drush-7

all: build

build:
	docker build --tag=${DOCKER_IMAGE}:${VERSION} .

push:
	docker push ${DOCKER_IMAGE}:${VERSION}

build-for-private-registry:
	docker build --tag=${REGISTRY_URL}/${DOCKER_IMAGE}:${VERSION} .

push-for-private-registry:
	docker push ${PRIVATE_REGISTRY_URL}/${DOCKER_IMAGE}:${VERSION}

