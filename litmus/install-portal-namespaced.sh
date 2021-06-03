#!/bin/bash

source litmus/utils.sh

path=$(pwd)
default_portal_port=9091
version=${PORTAL_VERSION}
loadBalancer=${LOAD_BALANCER}
LITMUS_PORTAL_NAMESPACE=${PORTAL_NAMESPACE}

# Namespaced Portal Setup
kubectl create ns ${LITMUS_PORTAL_NAMESPACE}
kubectl apply -f https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/litmus-portal-crds.yml
curl https://raw.githubusercontent.com/litmuschaos/litmus/master/docs/2.0.0-Beta/litmus-namespaced-2.0.0-Beta.yaml --output litmus-portal-namespaced-k8s-setup.yml
envsubst < litmus-portal-namespaced-k8s-setup.yml > ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-setup.yml

manifest_image_update $version ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-setup.yml

kubectl apply -f ${LITMUS_PORTAL_NAMESPACE}-ns-scoped-litmus-portal-setup.yml -n ${LITMUS_PORTAL_NAMESPACE}


## TODO: To be Removed
kubectl get pods -n ${LITMUS_PORTAL_NAMESPACE}

echo "-------- Waiting for all pods to be ready-----------"
# Waiting for pods to be ready (timeout - 180s)
wait_for_pods ${LITMUS_PORTAL_NAMESPACE} 360

echo "------------- Verifying Namespace, Deployments, pods and Images for Litmus-Portal ------------------"
# Namespace verification
verify_namespace ${LITMUS_PORTAL_NAMESPACE}

# Deployments verification
verify_deployment litmusportal-frontend ${LITMUS_PORTAL_NAMESPACE}
verify_deployment litmusportal-server ${LITMUS_PORTAL_NAMESPACE}

# Pods verification
verify_pod litmusportal-frontend ${LITMUS_PORTAL_NAMESPACE}
verify_pod litmusportal-server ${LITMUS_PORTAL_NAMESPACE}

# Images verification
verify_deployment_image $version litmusportal-frontend ${LITMUS_PORTAL_NAMESPACE}
verify_deployment_image $version litmusportal-server ${LITMUS_PORTAL_NAMESPACE}

if [[ "$loadBalancer" == "true" ]];then
    # Getting The LoadBalancer IP for accessing Litmus-Portal
    kubectl patch svc litmusportal-frontend-service -p '{"spec": {"type": "LoadBalancer"}}' -n ${LITMUS_PORTAL_NAMESPACE}

    wait_for_loadbalancer litmusportal-frontend-service ${LITMUS_PORTAL_NAMESPACE}

    IP=$(kubectl get svc litmusportal-frontend-service -n ${LITMUS_PORTAL_NAMESPACE} --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}"); 

    URL=http://$IP:$default_portal_port

    # Waiting for URL to be active
    wait_for_url $URL

    echo "URL to access Litmus-Portal: $URL"

else
    kubectl port-forward svc/litmusportal-frontend-service 3001:9091 -n ${LITMUS_PORTAL_NAMESPACE} &
fi
