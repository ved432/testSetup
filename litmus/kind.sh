#!/bin/bash
set -e

echo "Setting up KIND cluster"

docker load -i node.tar 

kind create cluster --image kindest/node:v1.21.1 --wait=900s

exec "$@"