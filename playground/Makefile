DOCKER_COMPOSE ?= $(shell if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then echo 'docker compose'; elif command -v docker-compose >/dev/null 2>&1; then echo docker-compose; else echo 'docker compose'; fi)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
DOCKER_SUDO ?=
else
DOCKER_SUDO ?= sudo -E
endif

.PHONY: playground
playground:
	$(DOCKER_SUDO) $(DOCKER_COMPOSE) up -d

.PHONY: playground-build
playground-build:
	$(DOCKER_SUDO) $(DOCKER_COMPOSE) build

.PHONY: playground-clean
playground-clean:
	$(DOCKER_SUDO) $(DOCKER_COMPOSE) down
