#!/bin/bash

source litmus/utils.sh

version=${PORTAL_VERSION}
accessType=${ACCESS_TYPE}
namespace=${NAMEPACE}

echo -e "\n---------------Installing Litmus-Portal in Cluster Scope----------\n"
curl https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/cluster-k8s-manifest.yml --output litmus-portal-setup.yml
manifest_image_update $version litmus-portal-setup.yml

kubectl apply -f litmus-portal-setup.yml

echo -e "\n---------------Pods running in ${namespace} Namespace---------------\n"
kubectl get pods -n ${namespace}

echo -e "\n---------------Waiting for all pods to be ready---------------\n"
# Waiting for pods to be ready (timeout - 360s)
wait_for_pods ${namespace} 360

echo -e "\n------------- Verifying Namespace, Deployments, pods and Images for Litmus-Portal ------------------\n"
# Namespace verification
verify_namespace ${namespace}

# Deployments verification
verify_all_components litmusportal-frontend,litmusportal-server ${namespace}

# Pods verification
verify_pod litmusportal-frontend ${namespace}
verify_pod litmusportal-server ${namespace}
verify_pod mongo ${namespace}

# Images verification
verify_deployment_image $version litmusportal-frontend ${namespace}
verify_deployment_image $version litmusportal-server ${namespace}

get_access_point ${namespace} ${accessType}