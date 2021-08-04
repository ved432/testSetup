#!/bin/bash

source litmus/utils.sh

version=${PORTAL_VERSION}
loadBalancer=${LOAD_BALANCER}

echo -e "\n---------------Installing Litmus-Portal using Manifest----------\n"
curl https://raw.githubusercontent.com/litmuschaos/litmus/master/litmus-portal/cluster-k8s-manifest.yml --output litmus-portal-setup.yml
manifest_image_update $version litmus-portal-setup.yml

kubectl apply -f litmus-portal-setup.yml

echo -e "\n---------------Pods running in Litmus Namespace---------------\n"
kubectl get pods -n litmus

echo -e "\n---------------Waiting for all pods to be ready---------------\n"
# Waiting for pods to be ready (timeout - 360s)
wait_for_pods litmus 360

echo -e "\n------------- Verifying Namespace, Deployments, pods and Images for Litmus-Portal ------------------\n"
# Namespace verification
verify_namespace litmus

# Deployments verification
verify_all_components litmusportal-frontend,litmusportal-server litmus

# Pods verification
verify_pod litmusportal-frontend litmus
verify_pod litmusportal-server litmus
verify_pod mongo litmus

# Images verification
verify_deployment_image $version litmusportal-frontend litmus
verify_deployment_image $version litmusportal-server litmus

# Updating the svc to ClusterIP
kubectl patch svc litmusportal-frontend-service -n litmus -p '{"spec": {"type": "ClusterIP"}}'
kubectl patch svc litmusportal-server-service -n litmus -p '{"spec": {"type": "ClusterIP"}}'

# Installing ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 3.33.0 --namespace litmus

wait_for_pods litmus 360

# Applying Ingress Manifest for Accessing Portal
kubectl apply -f litmus/ingress.yml -n litmus

wait_for_ingress litmus-ingress litmus

# Ingress IP for accessing Portal
export AccessURL=$(kubectl get ing litmus-ingress -n litmus -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' | awk '{print $1}')

echo "URL=$AccessURL" >> $GITHUB_ENV