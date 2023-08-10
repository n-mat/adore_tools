#!/usr/bin/env bash

export VAGRANT_VAGRANTFILE=Vagrantfile.headless
vagrant halt -f && vagrant destroy -f && vagrant up && vagrant ssh
