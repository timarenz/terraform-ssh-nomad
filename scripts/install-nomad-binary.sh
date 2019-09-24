#!/bin/bash

set -e

sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
nomad --version

nomad -autocomplete-uninstall || true
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad