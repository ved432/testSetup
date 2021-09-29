const KUBE_API_SERVER = Cypress.env("KUBE_API_SERVER");

const apis = {
  getWorkflows: (namespace) => {
    return `${KUBE_API_SERVER}/apis/argoproj.io/v1alpha1/namespaces/${namespace}/workflows`;
  },

  getCronWorkflows: (namespace) => {
    return `${KUBE_API_SERVER}/apis/argoproj.io/v1alpha1/namespaces/${namespace}/cronworkflows`;
  },

  getPods: (namespace) => {
    return `${KUBE_API_SERVER}/api/v1/namespaces/${namespace}/pods`;
  },

  getPodByLabel: (namespace, label) => {
    return `${KUBE_API_SERVER}/api/v1/namespaces/${namespace}/pods?labelSelector=${label}`;
  },

  getChaosEngines: (namespace) => {
    return `${KUBE_API_SERVER}/apis/litmuschaos.io/v1alpha1/namespaces/${namespace}/chaosresults`;
  },
};

export default apis;
