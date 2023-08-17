SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")


.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: install_vagrant_plugins
install_vagrant_plugins:
	@if vagrant plugin list | grep -q 'vagrant-reload'; then \
        echo "vagrant-reload plugin is already installed."; \
    else \
        echo "Installing vagrant-reload plugin..."; \
        vagrant plugin install vagrant-reload; \
    fi

.PHONY: up
up: up_headed

.PHONY: up_headless
up_headless: destroy install_vagrant_plugins start_vagrant_headless

.PHONY: up_headed
up_headed: destroy install_vagrant_plugins start_vagrant_headed

.PHONY: start_vagrant_headless
start_vagrant_headless: ## Start a virtualbox VM with no display active
	VAGRANT_VAGRANTFILE=Vagrantfile.headless vagrant up

.PHONY: start_vagrant_headed
start_vagrant_headed: ## Start a virtualbox VM with an active display and desktop environment
	VAGRANT_VAGRANTFILE=Vagrantfile.headed vagrant up

.PHONY: ssh
ssh: ## Connect to running VM
	VAGRANT_VAGRANTFILE=Vagrantfile.headless vagrant ssh || true
	VAGRANT_VAGRANTFILE=Vagrantfile.headed vagrant ssh || true

.PHONY: halt
halt: ## Halt running VM
	VAGRANT_VAGRANTFILE=Vagrantfile.headless vagrant halt -f || true
	VAGRANT_VAGRANTFILE=Vagrantfile.headed vagrant halt -f || true

.PHONY: destroy
destroy: ## Destory VM
	vagrant destroy -f

