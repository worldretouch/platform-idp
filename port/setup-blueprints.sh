#!/usr/bin/env bash
set -euo pipefail

# Create/update ALL Port.io blueprints + optional cluster entity.
#
# Usage:
#   PORT_ACCESS_TOKEN=... bash port/setup-blueprints.sh [options]
#
# Options:
#   --cluster-name     Cluster entity identifier (default: platform-cluster)
#   --cluster-title    Display title (default: Platform Cluster)
#   --provider         Cloud provider: digitalocean|aws|gcp|azure|on-prem (default: digitalocean)
#   --region           Region (default: sgp1)
#   --k8s-version      Kubernetes version (auto-detected if kubectl available)
#   --api-server-url   API server URL (auto-detected if kubectl available)
#   --skip-entity      Skip cluster entity creation

PORT_BASE_URL="${PORT_BASE_URL:-https://api.port.io}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLUSTER_NAME="platform-cluster"
CLUSTER_TITLE="Platform Cluster"
PROVIDER="digitalocean"
REGION="sgp1"
K8S_VERSION=""
API_SERVER_URL=""
SKIP_ENTITY="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cluster-name)    CLUSTER_NAME="$2"; shift 2 ;;
    --cluster-title)   CLUSTER_TITLE="$2"; shift 2 ;;
    --provider)        PROVIDER="$2"; shift 2 ;;
    --region)          REGION="$2"; shift 2 ;;
    --k8s-version)     K8S_VERSION="$2"; shift 2 ;;
    --api-server-url)  API_SERVER_URL="$2"; shift 2 ;;
    --skip-entity)     SKIP_ENTITY="true"; shift 1 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "${PORT_ACCESS_TOKEN:-}" ]]; then
  echo "Error: PORT_ACCESS_TOKEN is required"
  echo "Get one:"
  echo "  curl -s -X POST \"\${PORT_BASE_URL}/v1/auth/access_token\" \\"
  echo "    -H 'Content-Type: application/json' \\"
  echo "    -d '{\"clientId\":\"...\",\"clientSecret\":\"...\"}' | jq -r '.accessToken'"
  exit 1
fi

if [[ -z "$K8S_VERSION" ]] && command -v kubectl &>/dev/null; then
  K8S_VERSION=$(kubectl get nodes -o jsonpath='{.items[0].status.nodeInfo.kubeletVersion}' 2>/dev/null || echo "")
fi

if [[ -z "$API_SERVER_URL" ]] && command -v kubectl &>/dev/null; then
  API_SERVER_URL=$(kubectl cluster-info 2>/dev/null | head -1 | grep -oE 'https://[^ ]+' || echo "")
fi

upsert_blueprint() {
  local file="$1"
  local identifier
  identifier=$(jq -r '.identifier' "$file")

  echo -n "  Blueprint '${identifier}' ... "

  HTTP_CODE=$(curl -sS -o /tmp/port-bp-response.json -w "%{http_code}" \
    -X POST "${PORT_BASE_URL}/v1/blueprints" \
    -H "Authorization: Bearer ${PORT_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d @"$file")

  if [[ "$HTTP_CODE" == "409" ]]; then
    HTTP_CODE=$(curl -sS -o /tmp/port-bp-response.json -w "%{http_code}" \
      -X PATCH "${PORT_BASE_URL}/v1/blueprints/${identifier}" \
      -H "Authorization: Bearer ${PORT_ACCESS_TOKEN}" \
      -H "Content-Type: application/json" \
      -d @"$file")
    echo "updated (HTTP ${HTTP_CODE})"
  elif [[ "$HTTP_CODE" =~ ^2 ]]; then
    echo "created (HTTP ${HTTP_CODE})"
  else
    echo "FAILED (HTTP ${HTTP_CODE})"
    cat /tmp/port-bp-response.json
    echo
    return 1
  fi
}

echo "=== Port.io Blueprint Setup (${PORT_BASE_URL}) ==="
echo

echo "[1/3] Creating service blueprints..."
upsert_blueprint "${SCRIPT_DIR}/blueprints/api-service.json"
echo

echo "[2/3] Creating K8s & ArgoCD blueprints..."
upsert_blueprint "${SCRIPT_DIR}/blueprints/k8s-cluster.json"
upsert_blueprint "${SCRIPT_DIR}/blueprints/k8s-namespace.json"
upsert_blueprint "${SCRIPT_DIR}/blueprints/k8s-workload.json"
upsert_blueprint "${SCRIPT_DIR}/blueprints/k8s-replicaset.json"
upsert_blueprint "${SCRIPT_DIR}/blueprints/k8s-pod.json"
upsert_blueprint "${SCRIPT_DIR}/blueprints/argocd-app.json"
echo

if [[ "$SKIP_ENTITY" == "true" ]]; then
  echo "[3/3] Skipping cluster entity (--skip-entity)"
else
  echo "[3/3] Creating cluster entity '${CLUSTER_NAME}'..."

  ENTITY_PAYLOAD=$(jq -nc \
    --arg id "$CLUSTER_NAME" \
    --arg title "$CLUSTER_TITLE" \
    --arg provider "$PROVIDER" \
    --arg region "$REGION" \
    --arg version "${K8S_VERSION:-}" \
    --arg api_server "${API_SERVER_URL:-}" \
    '{
      identifier: $id,
      title: $title,
      properties: {
        provider: $provider,
        region: $region,
        version: $version,
        api_server_url: $api_server
      }
    } | .properties |= with_entries(select(.value != ""))')

  HTTP_CODE=$(curl -sS -o /tmp/port-entity-response.json -w "%{http_code}" \
    -X POST "${PORT_BASE_URL}/v1/blueprints/k8s_cluster/entities?upsert=true" \
    -H "Authorization: Bearer ${PORT_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$ENTITY_PAYLOAD")

  if [[ "$HTTP_CODE" =~ ^2 ]]; then
    echo "  Entity '${CLUSTER_NAME}' created/updated (HTTP ${HTTP_CODE})"
  else
    echo "  FAILED (HTTP ${HTTP_CODE})"
    cat /tmp/port-entity-response.json
    echo
  fi
fi

echo
echo "=== Done ==="
echo
echo "Next steps:"
echo
echo "  1. Install K8s exporter:"
echo "     helm upgrade --install ${CLUSTER_NAME} port-labs/port-k8s-exporter \\"
echo "       --create-namespace --namespace port-k8s-exporter \\"
echo "       --set secret.secrets.portClientId=\"\$PORT_CLIENT_ID\" \\"
echo "       --set secret.secrets.portClientSecret=\"\$PORT_CLIENT_SECRET\" \\"
echo "       --set portBaseUrl=\"${PORT_BASE_URL}\" \\"
echo "       --set stateKey=\"${CLUSTER_NAME}\" \\"
echo "       --set createDefaultResources=false \\"
echo "       --set overwriteConfigurationOnRestart=true \\"
echo "       --set eventListener.type=\"POLLING\" \\"
echo "       --set \"extraEnv[0].name=CLUSTER_NAME\" \\"
echo "       --set \"extraEnv[0].value=${CLUSTER_NAME}\" \\"
echo "       --set-file configMap.config=port/exporter/config.yaml"
echo
echo "  2. Create self-service actions (see port/actions/*.json)"
