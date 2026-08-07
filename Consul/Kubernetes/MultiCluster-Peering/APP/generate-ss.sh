#!/bin/bash

set -euo pipefail

###############################################################################
# Configuration
###############################################################################

TEMPLATE="static-server.yaml"

if [[ ! -f "${TEMPLATE}" ]]; then
    echo "ERROR: ${TEMPLATE} not found."
    exit 1
fi

###############################################################################
# Applications
# Format:
# App Name | Kubernetes Context | Namespace | Datacenter
###############################################################################

APPS=(
"static-server-dpdns-dc1|kind-cluster1|default|dc1"
"static-server-dpcns-dc1|kind-cluster1|nsdp-dc1|dc1"
"static-server-apdns-dc1|kind-cluster2|default|dc1"
"static-server-apcns-dc1|kind-cluster2|nsap-dc1|dc1"
"static-server-apcons-dc1|kind-cluster2|consul|dc1"
"static-server-dpdns-dc2|kind-cluster3|default|dc2"
"static-server-dpcns-dc2|kind-cluster3|nsdp-dc2|dc2"
"static-server-apdns-dc2|kind-cluster4|default|dc2"
"static-server-apcns-dc2|kind-cluster4|nsap-dc2|dc2"
)

###############################################################################
# Generate manifests
###############################################################################

echo
echo "============================================================"
echo "Generating application manifests..."
echo "============================================================"

for ITEM in "${APPS[@]}"; do

    APP=$(echo "${ITEM}" | cut -d'|' -f1)
    CONTEXT=$(echo "${ITEM}" | cut -d'|' -f2)
    NAMESPACE=$(echo "${ITEM}" | cut -d'|' -f3)
    DC=$(echo "${ITEM}" | cut -d'|' -f4)

    OUTPUT="${APP}.yaml"

    cp "${TEMPLATE}" "${OUTPUT}"

    # Replace application name everywhere
    sed -i '' "s/static-server/${APP}/g" "${OUTPUT}"

    # Replace response text
sed -i '' "s/hello world from dc1/Application=${APP}, Cluster=${CONTEXT}, Namespace=${NAMESPACE}, Datacenter=${DC}/g" "${OUTPUT}"

    echo "✔ Generated ${OUTPUT}"

done

###############################################################################
# Deploy applications
###############################################################################

echo
echo "============================================================"
echo "Deploying applications..."
echo "============================================================"

for ITEM in "${APPS[@]}"; do

    APP=$(echo "${ITEM}" | cut -d'|' -f1)
    CONTEXT=$(echo "${ITEM}" | cut -d'|' -f2)
    NAMESPACE=$(echo "${ITEM}" | cut -d'|' -f3)

    echo
    echo "------------------------------------------------------------"
    echo "Application : ${APP}"
    echo "Context     : ${CONTEXT}"
    echo "Namespace   : ${NAMESPACE}"
    echo "------------------------------------------------------------"

    # Create namespace if needed
    if kubectl get namespace "${NAMESPACE}" \
        --context "${CONTEXT}" >/dev/null 2>&1; then
        echo "Namespace '${NAMESPACE}' already exists."
    else
        echo "Creating namespace '${NAMESPACE}'..."
        kubectl create namespace "${NAMESPACE}" \
            --context "${CONTEXT}"
    fi

    kubectl apply \
        --context "${CONTEXT}" \
        --namespace "${NAMESPACE}" \
        -f "${APP}.yaml"

done

###############################################################################
# Summary
###############################################################################

echo
echo "============================================================"
echo "Deployment Complete"
echo "============================================================"
echo

printf "%-32s %-18s %-15s\n" "APPLICATION" "CLUSTER" "NAMESPACE"
printf "%-32s %-18s %-15s\n" "--------------------------------" "------------------" "---------------"

for ITEM in "${APPS[@]}"; do

    APP=$(echo "${ITEM}" | cut -d'|' -f1)
    CONTEXT=$(echo "${ITEM}" | cut -d'|' -f2)
    NAMESPACE=$(echo "${ITEM}" | cut -d'|' -f3)

    printf "%-32s %-18s %-15s\n" \
        "${APP}" \
        "${CONTEXT}" \
        "${NAMESPACE}"

done

echo
echo "All 9 applications deployed successfully."
