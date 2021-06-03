#!/bin/bash

source litmus/utils.sh

path=$(pwd)

version=${PORTAL_VERSION}
LITMUS_PORTAL_NAMESPACE=${PORTAL_NAMESPACE}

# Setting up the kubeconfig
# mkdir -p ~/.kube

# cp $path/.kube/config ~/.kube/config
# cp $path/.kube/admin.conf ~/.kube/config

# Shutting down the Litmus-Portal Setup
kubectl delete -f https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/litmus-portal-crds.yml
curl https://raw.githubusercontent.com/litmuschaos/litmus/master/docs/2.0.0-Beta/litmus-namespaced-2.0.0-Beta.yaml --output litmus-portal-namespaced-k8s-cleanup.yml
envsubst < litmus-portal-namespaced-k8s-cleanup.yml > ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-cleanup.yml

manifest_image_update $version ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-cleanup.yml

kubectl delete -f ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-cleanup.yml -n ${LITMUS_PORTAL_NAMESPACE}
