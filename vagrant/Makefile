SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")


.PHONY: help  
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: start_vagrant_headless
start_vagrant_headless: ## Start a virtualbox VM with no display active
	vagrant up

.PHONY: start_vagrant_headed
start_vagrant_headed: ## Start a virtualbox VM with an active display and desktop environment
	vagrant up

.PHONY: ssh
ssh: ## Connect to running VM
	vagrant ssh

.PHONY: halt
halt: ## Halt running VM
	vagrant halt -f

.PHONY: destroy
destroy: ## Destory VM
	vagrant destroy -f

