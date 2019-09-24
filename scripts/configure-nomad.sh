#!/bin/bash

set -e

sudo mkdir --parents /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo mv nomad.hcl /etc/nomad.d/nomad.hcl

sudo systemctl enable nomad.service
sudo systemctl restart nomad.service
sleep 5
sudo systemctl status nomad.service --no-pager