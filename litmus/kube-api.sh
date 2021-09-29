# Check all possible clusters, as your .KUBECONFIG may have multiple contexts:
kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

# Select name of cluster you want to interact with from above output:
export CLUSTER_NAME="k3d-qaTest"

# Point to the API server referring the cluster name
KUBE_API_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

# Gets the token value
KUBE_API_TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)

echo "KUBE_API_SERVER=$KUBE_API_SERVER" >> $GITHUB_ENV
echo "KUBE_API_TOKEN=$KUBE_API_TOKEN" >> $GITHUB_ENV