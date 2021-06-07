#!/bin/bash

source litmus/utils.sh

echo "Verifying all required Deployments"
verify_deployment litmusportal-frontend litmus
verify_deployment litmusportal-server litmus
verify_deployment chaos-operator-ce  litmus
verify_deployment event-tracker litmus
verify_deployment subscriber litmus
verify_deployment workflow-controller litmus
verify_deployment argo-server litmus

echo "Verifying all required Pods"
verify_pod litmusportal-frontend litmus
verify_pod litmusportal-server litmus
verify_pod mongo litmus
verify_pod chaos-operator-ce litmus
verify_pod event-tracker litmus
verify_pod subscriber litmus
verify_pod workflow-controller litmus
verify_pod argo-server litmus

echo "Waiting for all pods to be ready"
wait_for_pods litmus 360
