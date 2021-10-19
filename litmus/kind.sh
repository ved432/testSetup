#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

echo "Setting up KIND cluster"

docker load -i node.tar 

kind create cluster --image kindest/node:v1.21.1 --wait=900s

exec "$@"