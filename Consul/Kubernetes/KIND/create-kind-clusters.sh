#!/bin/bash

set -e

# =========================================================
# Ask user how many clusters to create
# =========================================================

read -p "Enter number of kind clusters to create: " NUM_CLUSTERS

if ! [[ "$NUM_CLUSTERS" =~ ^[0-9]+$ ]]; then
  echo "Invalid number"
  exit 1
fi

# =========================================================
# Check/Create shared docker network
# =========================================================

if docker network inspect kind-mesh >/dev/null 2>&1; then
  echo "Docker network 'kind-mesh' already exists. Skipping creation."
else
  echo "Creating docker network 'kind-mesh'..."
  docker network create kind-mesh --subnet=172.20.0.0/16
fi

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
name: ${CLUSTER_NAME}

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
  echo "Creating cluster ${CLUSTER_NAME}"
  echo "Pod CIDR     : 10.${POD_SECOND_OCTET}.0.0/16"
  echo "Service CIDR : 10.${SVC_SECOND_OCTET}.0.0/16"
  echo "NodePort     : ${NODE_PORT}"
  echo "======================================"

  KIND_EXPERIMENTAL_DOCKER_NETWORK=kind-mesh \
  kind create cluster \
    --name ${CLUSTER_NAME} \
    --config ${CLUSTER_NAME}.yaml

done

# =========================================================
# Gather node IPs
# =========================================================

NODE_IPS=()

echo ""
echo "Gathering node IPs..."
echo ""

for ((i=1; i<=NUM_CLUSTERS; i++)); do

  CLUSTER_NAME="cluster${i}"

  NODE_IPS[$i]=$(
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    ${CLUSTER_NAME}-control-plane
  )

  echo "${CLUSTER_NAME} node IP = ${NODE_IPS[$i]}"

done

# =========================================================
# Configure cross-cluster pod routing
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

      docker exec ${SRC_CLUSTER}-control-plane \
        ip route add ${POD_CIDR} via ${DST_NODE_IP} || true

    fi

  done

done

# =========================================================
# Install and configure MetalLB
# =========================================================

echo ""
echo "Installing MetalLB on all clusters..."
echo ""

for ((i=1; i<=NUM_CLUSTERS; i++)); do

  CLUSTER_NAME="cluster${i}"

  echo ""
  echo "======================================"
  echo "Installing MetalLB on ${CLUSTER_NAME}"
  echo "======================================"

  kubectl config use-context kind-${CLUSTER_NAME}

  kubectl apply -f \
    https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml


echo "Waiting for MetalLB controller webhook..."

kubectl wait \
  --namespace metallb-system \
  --for=condition=available deployment/controller \
  --timeout=90s

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
  - 172.20.255.${START_IP}-172.20.255.${END_IP}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: default
EOF

  kubectl apply -f metallb-${CLUSTER_NAME}.yaml

  echo "MetalLB configured for ${CLUSTER_NAME}"
  echo "IP Pool: 172.20.255.${START_IP}-172.20.255.${END_IP}"

done

echo ""
echo "======================================"
echo "Successfully created ${NUM_CLUSTERS} kind clusters"
echo "Full pod-to-pod connectivity configured"
echo "======================================"
