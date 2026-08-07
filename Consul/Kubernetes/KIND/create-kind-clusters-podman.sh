#!/bin/bash

set -euo pipefail

set -euo pipefail

NETWORK_NAME="kind"

# Check if the network exists
if ! podman network exists "${NETWORK_NAME}"; then
    echo "Network '${NETWORK_NAME}' does not exist."
    exit 0
fi

# Get containers attached to the network
CONTAINERS=$(podman network inspect "${NETWORK_NAME}" \
    --format '{{range $id, $c := .Containers}}{{$c.Name}} {{end}}')

if [[ -z "${CONTAINERS// }" ]]; then
    echo "No containers are attached to '${NETWORK_NAME}'."
    echo "Removing network..."
    podman network rm "${NETWORK_NAME}"
    echo "Network '${NETWORK_NAME}' removed."
    exit 0
fi

echo "The following containers are attached to '${NETWORK_NAME}':"
for c in ${CONTAINERS}; do
    echo "  - ${c}"
done
echo

read -p "Do you want to forcefully remove the network and these containers? (y/N): " ANSWER

case "${ANSWER}" in
    y|Y)
        echo
        echo "Removing containers..."
        for c in ${CONTAINERS}; do
            echo "  -> ${c}"
            podman rm -f "${c}"
        done

        echo
        echo "Removing network..."
        podman network rm "${NETWORK_NAME}"

        echo "Network '${NETWORK_NAME}' removed."
        ;;
    *)
        echo "Operation cancelled."
        ;;
esac

# =========================================================
# Detect container runtime (Podman preferred)
# =========================================================

if command -v podman >/dev/null 2>&1; then
    RUNTIME="podman"
    export KIND_EXPERIMENTAL_PROVIDER=podman
elif command -v docker >/dev/null 2>&1; then
    RUNTIME="docker"
else
    echo "❌ Neither podman nor docker is installed."
    exit 1
fi

echo "Using container runtime: ${RUNTIME}"

# =========================================================
# Ask user how many clusters to create
# =========================================================

read -p "Enter number of kind clusters to create: " NUM_CLUSTERS

if ! [[ "$NUM_CLUSTERS" =~ ^[0-9]+$ ]] || [ "$NUM_CLUSTERS" -lt 1 ]; then
    echo "Invalid number"
    exit 1
fi

# =========================================================
# Network configuration
# =========================================================


# =========================================================
# Create kind clusters
# =========================================================

for ((i=1; i<=NUM_CLUSTERS; i++)); do

    CLUSTER_NAME="cluster${i}"

    POD_SECOND_OCTET=$((i * 10))
    SVC_SECOND_OCTET=$((i * 10 + 1))
    NODE_PORT=$((32127 + i))

cat > ${CLUSTER_NAME}.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

networking:
  podSubnet: "10.${POD_SECOND_OCTET}.0.0/16"
  serviceSubnet: "10.${SVC_SECOND_OCTET}.0.0/16"

nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: ${NODE_PORT}
    hostPort: ${NODE_PORT}
    protocol: TCP
EOF

    echo ""
    echo "======================================"
    echo "Creating ${CLUSTER_NAME}"
    echo "Pod CIDR     : 10.${POD_SECOND_OCTET}.0.0/16"
    echo "Service CIDR : 10.${SVC_SECOND_OCTET}.0.0/16"
    echo "NodePort     : ${NODE_PORT}"
    echo "======================================"

    kind create cluster \
        --name ${CLUSTER_NAME} \
        --config ${CLUSTER_NAME}.yaml

done

# =========================================================
# Gather node IPs
# =========================================================

declare -a NODE_IPS

echo ""
echo "Gathering node IPs..."
echo ""

for ((i=1; i<=NUM_CLUSTERS; i++)); do

    CLUSTER_NAME="cluster${i}"

    NODE_IPS[$i]=$(
        ${RUNTIME} inspect \
        -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
        ${CLUSTER_NAME}-control-plane
    )

    echo "${CLUSTER_NAME} node IP = ${NODE_IPS[$i]}"

done

# =========================================================
# Configure pod routing
# =========================================================

echo ""
echo "Configuring pod-to-pod routes..."
echo ""

for ((SRC=1; SRC<=NUM_CLUSTERS; SRC++)); do

    SRC_CLUSTER="cluster${SRC}"

    for ((DST=1; DST<=NUM_CLUSTERS; DST++)); do

        if [ "$SRC" != "$DST" ]; then

            POD_CIDR="10.$((DST * 10)).0.0/16"
            DST_NODE_IP=${NODE_IPS[$DST]}

            echo "${SRC_CLUSTER} --> ${POD_CIDR} via ${DST_NODE_IP}"

            ${RUNTIME} exec ${SRC_CLUSTER}-control-plane \
                ip route add ${POD_CIDR} via ${DST_NODE_IP} || true
        fi

    done

done

# =========================================================
# Install MetalLB (latest stable)
# =========================================================

METALLB_VERSION="v0.15.2"

echo ""
echo "Installing MetalLB ${METALLB_VERSION} on all clusters..."
echo ""

for ((i=1; i<=NUM_CLUSTERS; i++)); do

    CLUSTER_NAME="cluster${i}"

    echo ""
    echo "======================================"
    echo "Installing MetalLB on ${CLUSTER_NAME}"
    echo "======================================"

    kubectl config use-context kind-${CLUSTER_NAME}

    kubectl apply -f \
      https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml

    echo "Waiting for MetalLB controller..."

    kubectl wait \
      --namespace metallb-system \
      --for=condition=available deployment/controller \
      --timeout=180s

    # -------------------------------------------------------
    # Create unique MetalLB IP pool per cluster
    # -------------------------------------------------------

    START_IP=$((200 + (i - 1) * 5))
    END_IP=$((START_IP + 4))

cat > metallb-${CLUSTER_NAME}.yaml <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: default-address-pool
spec:
  addresses:
  - 10.89.0.${START_IP}-10.89.0.${END_IP}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: default
EOF

    kubectl apply -f metallb-${CLUSTER_NAME}.yaml

    echo "MetalLB configured for ${CLUSTER_NAME}"
    echo "IP Pool: 10.89.0.${START_IP}-10.89.0.${END_IP}"

done

echo ""
echo "======================================"
echo "Successfully created ${NUM_CLUSTERS} Kind clusters"
echo "Container runtime : ${RUNTIME}"
echo "Shared network    : kind"
echo "Pod routing       : Configured"
echo "MetalLB version   : ${METALLB_VERSION}"
echo "======================================"

if [ "$RUNTIME" = "podman" ]; then
    echo ""
    echo "NOTE: On macOS, Podman runs inside a VM."
    echo "MetalLB IPs (10.89.x.x) are reachable from inside the Podman VM,"
    echo "but not directly from your macOS host unless additional networking"
    echo "or port forwarding is configured."
fi
