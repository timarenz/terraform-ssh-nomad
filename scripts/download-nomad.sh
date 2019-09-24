#!/bin/bash

set -e

GPG_KEY=91A6E7F85D05C65630BEF18951852D87348FFC4C
KEY_SERVER=hkp://keyserver.ubuntu.com:80
CHECKPOINT_URL="https://checkpoint-api.hashicorp.com/v1/check"

if [ -z "${NOMAD_VERSION}" ]; then
    NOMAD_VERSION=$(curl -s "${CHECKPOINT_URL}"/nomad | jq .current_version | tr -d '"')
fi

echo "Nomad version: ${NOMAD_VERSION}"

gpg --keyserver "${KEY_SERVER}" --recv-keys "${GPG_KEY}"

echo "Downloading Nomad binaries from releases.hashicorp.com..."
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig

gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS
grep nomad_${NOMAD_VERSION}_linux_amd64.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c 

unzip -o nomad_${NOMAD_VERSION}_linux_amd64.zip