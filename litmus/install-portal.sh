#!/bin/bash

source litmus/utils.sh

path=$(pwd)
default_portal_port=9091
version=${PORTAL_VERSION}
loadBalancer=${LOAD_BALANCER}

# # Setting up the kubeconfig
# mkdir -p ~/.kube

# cp $path/.kube/config ~/.kube/config
# cp $path/.kube/admin.conf ~/.kube/config

echo "----------------Installing Litmus-Portal----------------------"
curl https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/cluster-k8s-manifest.yml --output litmus-portal-setup.yml
manifest_image_update $version litmus-portal-setup.yml

kubectl apply -f litmus-portal-setup.yml

## TODO: To be Removed
kubectl get pods -n litmus

echo "-------- Waiting for all pods to be ready-----------"
# Waiting for pods to be ready (timeout - 180s)
wait_for_pods litmus 360

echo "------------- Verifying Namespace, Deployments, pods and Images for Litmus-Portal ------------------"
# Namespace verification
verify_namespace litmus

# Deployments verification
verify_deployment litmusportal-frontend litmus
verify_deployment litmusportal-server litmus

# Pods verification
verify_pod litmusportal-frontend litmus
verify_pod litmusportal-server litmus
verify_pod mongo litmus

# Images verification
verify_deployment_image $version litmusportal-frontend litmus
verify_deployment_image $version litmusportal-server litmus

if [[ "$loadBalancer" == "true" ]];then
    # Getting The LoadBalancer IP for accessing Litmus-Portal
    kubectl patch svc litmusportal-frontend-service -p '{"spec": {"type": "LoadBalancer"}}' -n litmus

    wait_for_loadbalancer litmusportal-frontend-service litmus

    IP=$(kubectl get svc litmusportal-frontend-service -n litmus --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}"); 

    URL=http://$IP:$default_portal_port

    # Waiting for URL to be active
    wait_for_url $URL

    echo "URL to access Litmus-Portal: $URL"

else
    kubectl port-forward svc/litmusportal-frontend-service 3001:9091 -n litmus &
fi
