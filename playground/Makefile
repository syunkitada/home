UID := $(shell id -u)
GID := $(shell id -g)

.PHONY: playground
playground:
	UID=${UID} GID=${GID} sudo -E docker-compose up -d

.PHONY: playground-build
playground-build:
	UID=${UID} GID=${GID} sudo -E docker-compose build

.PHONY: playground-clean
playground-clean:
	UID=${UID} GID=${GID} sudo -E docker-compose down
