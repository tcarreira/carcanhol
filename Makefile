SHELL := /bin/bash

PROJECT ?= My Project
VERSION ?= $(shell git describe --tags --dirty --match='v*' 2> /dev/null || echo "$${DOCKER_BUILD_BIN_VERSION:-dev}")
COMMIT  ?= $(shell git rev-parse --short HEAD 2> /dev/null || echo "")
DATEUTC ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Prepend a space to variables so they don't show up in make showconf
 GREEN  := $(shell tput -Txterm setaf 2 2>/dev/null)
 YELLOW := $(shell tput -Txterm setaf 3 2>/dev/null)
 WHITE  := $(shell tput -Txterm setaf 7 2>/dev/null)
 CYAN   := $(shell tput -Txterm setaf 6 2>/dev/null)
 RESET  := $(shell tput -Txterm sgr0    2>/dev/null)

.PHONY: help showconf

default: help

## Help:
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

showconf: ## Show some config envs
	@exit 0 # Required to prevent make from exiting with non-zero code
	$(info ${YELLOW}Current variable values:${RESET})
	$(foreach v, \
			$(shell grep -E '^[A-Za-z][A-Za-z_-]* *.?=.*' $(MAKEFILE_LIST) | sed -E 's|^([A-Za-z][A-Za-z_-]*).*$$|\1|g' | sort), \
			$(info $(shell printf '  ${CYAN}%-10s=${RESET} %s\n' '$(v)' "$(shell printf '%s' '$($(v))' | cat -v)" )))

## Development

run:  ## run app with docker compose
	@docker compose up --build --remove-orphans --renew-anon-volumes
