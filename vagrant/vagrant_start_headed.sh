#!/usr/bin/env bash

export VAGRANT_VAGRANTFILE=Vagrantfile.headed
vagrant halt -f && vagrant destroy -f && vagrant up && vagrant ssh
