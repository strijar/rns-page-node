# Makefile for rns-page-node

# Extract version from pyproject.toml
VERSION := $(shell grep "^version =" pyproject.toml | cut -d '"' -f 2)
VCS_REF := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Detect if docker buildx is available
DOCKER_BUILD := $(shell docker buildx version >/dev/null 2>&1 && echo "docker buildx build" || echo "docker build")
DOCKER_BUILD_LOAD := $(shell docker buildx version >/dev/null 2>&1 && echo "docker buildx build --load" || echo "docker build")

# Build arguments for Docker
DOCKER_BUILD_ARGS := --build-arg VERSION=$(VERSION) \
                     --build-arg VCS_REF=$(VCS_REF) \
                     --build-arg BUILD_DATE=$(BUILD_DATE)

.PHONY: all build sdist wheel clean install lint format docker-wheels docker-build docker-run docker-build-rootless docker-run-rootless help test docker-test

all: build

build: clean
	python3 -m build

sdist:
	python3 -m build --sdist

wheel:
	python3 -m build --wheel

clean:
	rm -rf build dist *.egg-info

install: build
	pip install dist/*.whl

lint:
	ruff check .

format:
	ruff check --fix .

docker-wheels:
	$(DOCKER_BUILD) --target builder -f docker/Dockerfile.build -t rns-page-node-builder .
	docker create --name builder-container rns-page-node-builder true
	docker cp builder-container:/src/dist ./dist
	docker rm builder-container

docker-build:
	$(DOCKER_BUILD_LOAD) $(DOCKER_BUILD_ARGS) $(BUILD_ARGS) -f docker/Dockerfile -t git.quad4.io/rns-things/rns-page-node:latest -t git.quad4.io/rns-things/rns-page-node:$(VERSION) .

docker-run:
	docker run --rm -it \
		-v ./pages:/app/pages \
		-v ./files:/app/files \
		-v ./node-config:/app/node-config \
		git.quad4.io/rns-things/rns-page-node:latest \
		--node-name "Page Node" \
		--pages-dir /app/pages \
		--files-dir /app/files \
		--identity-dir /app/node-config \
		--announce-interval 360

docker-build-rootless:
	$(DOCKER_BUILD_LOAD) $(DOCKER_BUILD_ARGS) $(BUILD_ARGS) -f docker/Dockerfile.rootless -t git.quad4.io/rns-things/rns-page-node:latest-rootless -t git.quad4.io/rns-things/rns-page-node:$(VERSION)-rootless .

docker-run-rootless:
	docker run --rm -it \
		-v ./pages:/app/pages \
		-v ./files:/app/files \
		-v ./node-config:/app/node-config \
		git.quad4.io/rns-things/rns-page-node:latest-rootless \
		--node-name "Page Node" \
		--pages-dir /app/pages \
		--files-dir /app/files \
		--identity-dir /app/node-config \
		--announce-interval 360

test:
	bash tests/run_tests.sh

docker-test:
	$(DOCKER_BUILD_LOAD) -f docker/Dockerfile.tests -t rns-page-node-tests .
	docker run --rm rns-page-node-tests

help:
	@echo "Makefile commands:"
	@echo "  all            - alias for build"
	@echo "  build          - clean and build sdist and wheel"
	@echo "  sdist          - build source distribution"
	@echo "  wheel          - build wheel"
	@echo "  clean          - remove build artifacts"
	@echo "  install        - install built wheel"
	@echo "  lint           - run ruff linter"
	@echo "  format         - run ruff --fix"
	@echo "  docker-wheels  - build Python wheels in Docker"
	@echo "  docker-build   - build runtime Docker image (version: $(VERSION))"
	@echo "  docker-run     - run runtime Docker image"
	@echo "  docker-build-rootless - build rootless runtime Docker image"
	@echo "  docker-run-rootless  - run rootless runtime Docker image"
	@echo "  test                 - run local integration tests"
	@echo "  docker-test          - build and run integration tests in Docker"
