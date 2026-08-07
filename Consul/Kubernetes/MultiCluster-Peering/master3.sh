#!/usr/bin/env bash

set -euo pipefail

# --- Pre-requisites Check ---
command -v kind >/dev/null 2>&1 || { echo "kind is required but not installed. Aborting." >&2; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed. Aborting." >&2; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "helm is required but not installed. Aborting." >&2; exit 1; }

# --- Helper Functions ---
wait_for_nodes_ready() {
    local ctx=$1
    echo "Waiting for Kubernetes nodes in context '${ctx}' to reach 'Ready' state..."
    kubectl --context "${ctx}" wait --for=condition=Ready nodes --all --timeout=300s
}

wait_for_service_ip() {
    local ctx=$1
    local svc=$2
    local ns=$3
    # REDIRECTED TO STDERR (>&2) so it doesn't get captured by the variable assignment!
    echo "Waiting for LoadBalancer IP for service '${svc}' in namespace '${ns}' on context '${ctx}'..." >&2
    
    local ip=""
    while [ -z "$ip" ]; do
        ip=$(kubectl --context "${ctx}" get svc "${svc}" -n "${ns}" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
        if [ -z "$ip" ]; then
            ip=$(kubectl --context "${ctx}" get svc "${svc}" -n "${ns}" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
        fi
        if [ -z "$ip" ]; then
            sleep 5
        fi
    done
    
    # Only the actual IP goes to stdout
    echo "$ip"
}

get_k8s_auth_url() {
    local ctx=$1
    local node_ip
    node_ip=$(kubectl --context "${ctx}" get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    echo "https://${node_ip}:6443"
}

setup_namespace_and_license() {
    local ctx=$1
    echo "Setting up namespace and license in context '${ctx}'..."
    kubectl --context "${ctx}" create namespace consul --dry-run=client -o yaml | kubectl --context "${ctx}" apply -f -
    if [ -f "license.hclic" ]; then
        kubectl --context "${ctx}" create secret generic license \
            --namespace consul \
            --from-file=key=license.hclic \
            --dry-run=client -o yaml | kubectl --context "${ctx}" apply -f -
    else
        echo "Warning: license.hclic not found in current directory. Skipping license secret creation."
    fi
}

copy_secrets() {
    local src_ctx=$1
    local dst_ctx=$2
    echo "Copying Consul CA secrets and Partition ACL token from '${src_ctx}' to '${dst_ctx}'..."
    
    until kubectl get secret consul-ca-cert --context "${src_ctx}" -n consul >/dev/null 2>&1; do
        sleep 3
    done

    kubectl get secret consul-ca-cert --context "${src_ctx}" -n consul -o yaml | \
        kubectl apply --namespace consul --context "${dst_ctx}" -f -

    kubectl get secret consul-ca-key --context "${src_ctx}" -n consul -o yaml | \
        kubectl apply --namespace consul --context "${dst_ctx}" -f -

    kubectl get secret consul-partitions-acl-token --context "${src_ctx}" -n consul -o yaml | \
        kubectl apply --namespace consul --context "${dst_ctx}" -f -
}

# ==============================================================================
# STEP 1: Create Kind Clusters & MetalLB
# ==============================================================================
echo "=== STEP 1: Creating Kind Clusters & Initializing MetalLB ==="
if [ -f "./updated_script.sh" ]; then
    chmod +x ./updated_script.sh
    ./updated_script.sh
    
    echo "Cluster creation script completed. Verifying node readiness across all clusters..."
    wait_for_nodes_ready "kind-cluster1"
    wait_for_nodes_ready "kind-cluster2"
    wait_for_nodes_ready "kind-cluster3"
    wait_for_nodes_ready "kind-cluster4"
    echo "All clusters are up and Ready!"
else
    echo "updated_script.sh not found! Skipping cluster creation assuming clusters exist."
fi

export HELM_RELEASE_SERVER1=server1
export HELM_RELEASE_CLIENT1=client1
export HELM_RELEASE_SERVER2=server2
export HELM_RELEASE_CLIENT2=client2

# ==============================================================================
# DC1: Setup Control Plane (cluster1) and Admin Partition Dataplane (cluster2)
# ==============================================================================
echo -e "\n=== STEP 2: Setting up DC1 (cluster1 -> Control Plane, cluster2 -> Dataplane) ==="
SERVER1_CTX="kind-cluster1"
CLIENT1_CTX="kind-cluster2"

setup_namespace_and_license "${SERVER1_CTX}"
setup_namespace_and_license "${CLIENT1_CTX}"

echo "Installing Consul on DC1 Control Plane (waiting until ready)..."
kubectl config use-context "${SERVER1_CTX}"
helm install "${HELM_RELEASE_SERVER1}" hashicorp/consul \
  --create-namespace --namespace consul \
  --values server1-values.yaml \
  --version=2.0.1 \
  --wait --timeout=10m

SERVER1_EXTERNAL_IP=$(wait_for_service_ip "${SERVER1_CTX}" "consul-expose-servers" "consul")
CLIENT1_K8S_AUTH_URL=$(get_k8s_auth_url "${CLIENT1_CTX}")

echo "Extracted DC1 Server External IP: ${SERVER1_EXTERNAL_IP}"
echo "Extracted DC1 Client K8s Auth URL: ${CLIENT1_K8S_AUTH_URL}"

copy_secrets "${SERVER1_CTX}" "${CLIENT1_CTX}"

# Create a clean override file for client 1
cat <<EOF > client1-dynamic-overrides.yaml
externalServers:
  hosts:
    - "${SERVER1_EXTERNAL_IP}"
  k8sAuthMethodHost: "${CLIENT1_K8S_AUTH_URL}"
EOF

echo "Installing Consul on DC1 Data Plane (waiting until ready)..."
kubectl config use-context "${CLIENT1_CTX}"
helm install "${HELM_RELEASE_CLIENT1}" hashicorp/consul \
  --create-namespace --namespace consul \
  --values client1-values.yaml \
  --values client1-dynamic-overrides.yaml \
  --version=2.0.1 \
  --wait --timeout=10m

# ==============================================================================
# DC2: Setup Control Plane (cluster3) and Admin Partition Dataplane (cluster4)
# ==============================================================================
echo -e "\n=== STEP 3: Setting up DC2 (cluster3 -> Control Plane, cluster4 -> Dataplane) ==="
SERVER2_CTX="kind-cluster3"
CLIENT2_CTX="kind-cluster4"

setup_namespace_and_license "${SERVER2_CTX}"
setup_namespace_and_license "${CLIENT2_CTX}"

echo "Installing Consul on DC2 Control Plane (waiting until ready)..."
kubectl config use-context "${SERVER2_CTX}"
helm install "${HELM_RELEASE_SERVER2}" hashicorp/consul \
  --create-namespace --namespace consul \
  --values server2-values.yaml \
  --version=2.0.1 \
  --wait --timeout=10m

SERVER2_EXTERNAL_IP=$(wait_for_service_ip "${SERVER2_CTX}" "consul-expose-servers" "consul")
CLIENT2_K8S_AUTH_URL=$(get_k8s_auth_url "${CLIENT2_CTX}")

echo "Extracted DC2 Server External IP: ${SERVER2_EXTERNAL_IP}"
echo "Extracted DC2 Client K8s Auth URL: ${CLIENT2_K8S_AUTH_URL}"

copy_secrets "${SERVER2_CTX}" "${CLIENT2_CTX}"

# Create a clean override file for client 2
cat <<EOF > client2-dynamic-overrides.yaml
externalServers:
  hosts:
    - "${SERVER2_EXTERNAL_IP}"
  k8sAuthMethodHost: "${CLIENT2_K8S_AUTH_URL}"
EOF

echo "Installing Consul on DC2 Data Plane (waiting until ready)..."
kubectl config use-context "${CLIENT2_CTX}"
helm install "${HELM_RELEASE_CLIENT2}" hashicorp/consul \
  --create-namespace --namespace consul \
  --values client2-values.yaml \
  --values client2-dynamic-overrides.yaml \
  --version=2.0.1 \
  --wait --timeout=10m

# ==============================================================================
# STEP 4: CONTROL PLANE PEERING
# ==============================================================================
echo -e "\n=== STEP 4: Control Plane Peering ==="
if [ -d "CONTROLPLANE_PEERING" ]; then
    pushd CONTROLPLANE_PEERING > /dev/null

    kubectl config use-context "${SERVER1_CTX}"
    kubectl apply -f mesh.yaml
    kubectl apply -f proxy-defaults.yaml
    kubectl apply -f acceptor.yaml

    echo "Waiting for peering-token secret to be generated by Consul..."
    until kubectl get secret peering-token >/dev/null 2>&1; do sleep 2; done
    kubectl get secret peering-token -o yaml > peering-token.yaml

    kubectl config use-context "${SERVER2_CTX}"
    kubectl apply -f mesh.yaml
    kubectl apply -f proxy-defaults.yaml
    kubectl apply -f peering-token.yaml
    kubectl apply -f dialer.yaml

    popd > /dev/null
else
    echo "Warning: CONTROLPLANE_PEERING directory not found, skipping Control Plane Peering."
fi

# ==============================================================================
# STEP 5: DATA PLANE PEERING
# ==============================================================================
echo -e "\n=== STEP 5: Data Plane Peering ==="
if [ -d "DATAPLANE_PEERING" ]; then
    pushd DATAPLANE_PEERING > /dev/null

    kubectl config use-context "${CLIENT1_CTX}"
    kubectl apply -f proxy-defaults.yaml
    kubectl apply -f acceptor.yaml

    echo "Waiting for peering-token secret to be generated by Consul..."
    until kubectl get secret peering-token >/dev/null 2>&1; do sleep 2; done
    kubectl get secret peering-token -o yaml > peering-token.yaml

    kubectl config use-context "${CLIENT2_CTX}"
    kubectl apply -f proxy-defaults.yaml
    kubectl apply -f peering-token.yaml
    kubectl apply -f dialer.yaml

    popd > /dev/null
else
    echo "Warning: DATAPLANE_PEERING directory not found, skipping Data Plane Peering."
fi

echo -e "\n=== Deployment Complete Successfully! ==="
