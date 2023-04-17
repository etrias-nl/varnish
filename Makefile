MAKEFLAGS += --warn-undefined-variables --always-make
.DEFAULT_GOAL := _

DOCKER_PROGRESS?=auto
DOCKER_IMAGE=etriasnl/varnish
VARNISH_VERSION=$(shell cat Dockerfile | grep 'FROM emgag/varnish:' | cut -f2 -d':' | cut -f1 -d ' ')
PATCH_VERSION=$$(($(shell curl -sS "https://hub.docker.com/v2/repositories/${DOCKER_IMAGE}/tags/?page_size=1&page=1&name=${VARNISH_VERSION}-&ordering=last_updated" | jq -r '.results[0].name' | cut -f2 -d '-') + 1))

exec_docker=docker run $(shell [ "$$CI" = true ] && echo "-t" || echo "-it") -u "$(shell id -u):$(shell id -g)" --rm -v "$(shell pwd):/app" -w /app

lint-yaml:
	${exec_docker} cytopia/yamllint .
lint-dockerfile:
	${exec_docker} hadolint/hadolint hadolint --ignore DL3006 --ignore DL3008 Dockerfile
lint: lint-yaml lint-dockerfile
release:
	git tag "${VARNISH_VERSION}-${PATCH_VERSION}"
	git push --tags
build: lint
	docker buildx build --progress "${DOCKER_PROGRESS}" --tag "$(shell git describe --tags)" .
