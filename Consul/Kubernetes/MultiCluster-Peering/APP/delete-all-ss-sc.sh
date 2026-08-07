#!/bin/bash

set -euo pipefail

###############################################################################
# Format:
# Resource Name | Kubernetes Context | Namespace
###############################################################################

APPS=(
# ---------------------------------------------------------------------------
# Static Servers
# ---------------------------------------------------------------------------
"static-server-dpdns-dc1|kind-cluster1|default"
"static-server-dpcns-dc1|kind-cluster1|nsdp-dc1"
"static-server-apdns-dc1|kind-cluster2|default"
"static-server-apcns-dc1|kind-cluster2|nsap-dc1"
"static-server-apcons-dc1|kind-cluster2|consul"
"static-server-dpdns-dc2|kind-cluster3|default"
"static-server-dpcns-dc2|kind-cluster3|nsdp-dc2"
"static-server-apdns-dc2|kind-cluster4|default"
"static-server-apcns-dc2|kind-cluster4|nsap-dc2"

# ---------------------------------------------------------------------------
# Static Clients
# ---------------------------------------------------------------------------
"static-client-dpdns-dc1|kind-cluster1|default"
"static-client-dpcns-dc1|kind-cluster1|nsdp-dc1"
"static-client-apdns-dc1|kind-cluster2|default"
"static-client-apcns-dc1|kind-cluster2|nsap-dc1"
"static-client-apcons-dc1|kind-cluster2|consul"
)

echo
echo "============================================================"
echo "Deleting static applications..."
echo "============================================================"

for ITEM in "${APPS[@]}"; do

    APP=$(echo "$ITEM" | cut -d'|' -f1)
    CONTEXT=$(echo "$ITEM" | cut -d'|' -f2)
    NAMESPACE=$(echo "$ITEM" | cut -d'|' -f3)

    echo
    echo "------------------------------------------------------------"
    echo "Application : ${APP}"
    echo "Context     : ${CONTEXT}"
    echo "Namespace   : ${NAMESPACE}"
    echo "------------------------------------------------------------"

    kubectl delete deployment "${APP}" \
        --context "${CONTEXT}" \
        --namespace "${NAMESPACE}" \
        --ignore-not-found

    kubectl delete service "${APP}" \
        --context "${CONTEXT}" \
        --namespace "${NAMESPACE}" \
        --ignore-not-found

    kubectl delete serviceaccount "${APP}" \
        --context "${CONTEXT}" \
        --namespace "${NAMESPACE}" \
        --ignore-not-found

done

echo
echo "============================================================"
echo "Cleanup completed successfully."
echo "============================================================"
