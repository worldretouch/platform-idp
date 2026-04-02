#!/usr/bin/env bash
set -euo pipefail

# Create/update Port.io dashboard pages from JSON configs.
#
# Each JSON file in port/dashboards/ defines one dashboard page.
# The "widgets" field is the dashboard-widget wrapper (layout + child widgets).
# This script stringifies it and POSTs to the Pages API.
#
# Usage:
#   PORT_ACCESS_TOKEN=... bash port/setup-dashboards.sh
#
# Requires: curl, jq

PORT_BASE_URL="${PORT_BASE_URL:-https://api.port.io}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DASHBOARDS_DIR="${SCRIPT_DIR}/dashboards"

if [[ -z "${PORT_ACCESS_TOKEN:-}" ]]; then
  echo "Error: PORT_ACCESS_TOKEN is required"
  echo "Get one:"
  echo "  curl -s -X POST \"\${PORT_BASE_URL}/v1/auth/access_token\" \\"
  echo "    -H 'Content-Type: application/json' \\"
  echo "    -d '{\"clientId\":\"...\",\"clientSecret\":\"...\"}' | jq -r '.accessToken'"
  exit 1
fi

upsert_dashboard() {
  local file="$1"
  local identifier title icon description widgets_json page_payload

  identifier=$(jq -r '.identifier' "$file")
  title=$(jq -r '.title' "$file")
  icon=$(jq -r '.icon' "$file")
  description=$(jq -r '.description // ""' "$file")

  # The "widgets" field in our JSON is the dashboard-widget object.
  # Port API expects widgets as an array of objects (not strings).
  page_payload=$(jq -nc \
    --arg id "$identifier" \
    --arg title "$title" \
    --arg icon "$icon" \
    --arg desc "$description" \
    --argjson widgets "$(jq -c '.widgets' "$file")" \
    '{
      identifier: $id,
      title: $title,
      icon: $icon,
      description: $desc,
      type: "dashboard",
      widgets: [$widgets]
    }')

  echo -n "  Dashboard '${identifier}' (${title}) ... "

  HTTP_CODE=$(curl -sS -o /tmp/port-dash-response.json -w "%{http_code}" \
    -X POST "${PORT_BASE_URL}/v1/pages" \
    -H "Authorization: Bearer ${PORT_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$page_payload")

  if [[ "$HTTP_CODE" == "409" ]]; then
    # PATCH does not accept "type" or "identifier" fields
    local patch_payload
    patch_payload=$(echo "$page_payload" | jq 'del(.type, .identifier)')

    HTTP_CODE=$(curl -sS -o /tmp/port-dash-response.json -w "%{http_code}" \
      -X PATCH "${PORT_BASE_URL}/v1/pages/${identifier}" \
      -H "Authorization: Bearer ${PORT_ACCESS_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$patch_payload")
    echo "updated (HTTP ${HTTP_CODE})"
  elif [[ "$HTTP_CODE" =~ ^2 ]]; then
    echo "created (HTTP ${HTTP_CODE})"
  else
    echo "FAILED (HTTP ${HTTP_CODE})"
    cat /tmp/port-dash-response.json
    echo
    return 1
  fi
}

echo "=== Port.io Dashboard Setup (${PORT_BASE_URL}) ==="
echo

if [[ ! -d "$DASHBOARDS_DIR" ]]; then
  echo "Error: Dashboards directory not found: ${DASHBOARDS_DIR}"
  exit 1
fi

count=0
for dashboard_file in "${DASHBOARDS_DIR}"/*.json; do
  [[ -f "$dashboard_file" ]] || continue
  upsert_dashboard "$dashboard_file"
  count=$((count + 1))
done

echo
echo "=== Done (${count} dashboards) ==="
