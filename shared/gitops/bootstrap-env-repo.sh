#!/usr/bin/env bash
set -euo pipefail

# Bootstrap an environment repo from shared/gitops skeleton.
# Usage:
#   bash shared/gitops/bootstrap-env-repo.sh \
#     --target-dir ../platform-env \
#     --env-repo-url https://github.com/myorg/platform-env.git \
#     --template-repo-url https://github.com/myorg/platform-idp.git \
#     --argocd-namespace argocd \
#     --cluster-api-server https://kubernetes.default.svc
#     --github-org myorg   # GHCR image path ghcr.io/<org>/<service>

TARGET_DIR=""
ENV_REPO_URL=""
TEMPLATE_REPO_URL=""
GITHUB_ORG="myorg"
ARGOCD_NAMESPACE="argocd"
CLUSTER_API_SERVER="https://kubernetes.default.svc"
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --env-repo-url)
      ENV_REPO_URL="$2"
      shift 2
      ;;
    --template-repo-url)
      TEMPLATE_REPO_URL="$2"
      shift 2
      ;;
    --argocd-namespace)
      ARGOCD_NAMESPACE="$2"
      shift 2
      ;;
    --cluster-api-server)
      CLUSTER_API_SERVER="$2"
      shift 2
      ;;
    --github-org)
      GITHUB_ORG="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift 1
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "${TARGET_DIR}" || -z "${ENV_REPO_URL}" || -z "${TEMPLATE_REPO_URL}" ]]; then
  echo "Missing required args."
  echo "Required: --target-dir --env-repo-url --template-repo-url"
  exit 1
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Target dir not found: ${TARGET_DIR}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKELETON_ROOT="${SCRIPT_DIR}"

run_cmd() {
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

run_cmd mkdir -p "${TARGET_DIR}/argocd"
run_cmd mkdir -p "${TARGET_DIR}/environments/dev/apps" "${TARGET_DIR}/environments/dev/values"
run_cmd mkdir -p "${TARGET_DIR}/environments/staging/apps" "${TARGET_DIR}/environments/staging/values"
run_cmd mkdir -p "${TARGET_DIR}/environments/prod/apps" "${TARGET_DIR}/environments/prod/values"
run_cmd mkdir -p "${TARGET_DIR}/.github/workflows"

run_cmd cp -f "${SKELETON_ROOT}/promote-to-env.example.yml" "${TARGET_DIR}/.github/workflows/promote-to-env.yml"
run_cmd cp -f "${SKELETON_ROOT}/argocd/project-platform-services.yaml" "${TARGET_DIR}/argocd/"
run_cmd cp -f "${SKELETON_ROOT}/argocd/platform-argocd-config-app.yaml" "${TARGET_DIR}/argocd/"
run_cmd cp -f "${SKELETON_ROOT}/argocd/root-app.yaml" "${TARGET_DIR}/argocd/"
run_cmd cp -f "${SKELETON_ROOT}/environments/dev/apps/orders-api.yaml" "${TARGET_DIR}/environments/dev/apps/"
run_cmd cp -f "${SKELETON_ROOT}/environments/staging/apps/orders-api.yaml" "${TARGET_DIR}/environments/staging/apps/"
run_cmd cp -f "${SKELETON_ROOT}/environments/prod/apps/orders-api.yaml" "${TARGET_DIR}/environments/prod/apps/"
run_cmd cp -f "${SKELETON_ROOT}/environments/dev/values/orders-api.values.yaml" "${TARGET_DIR}/environments/dev/values/"
run_cmd cp -f "${SKELETON_ROOT}/environments/staging/values/orders-api.values.yaml" "${TARGET_DIR}/environments/staging/values/"
run_cmd cp -f "${SKELETON_ROOT}/environments/prod/values/orders-api.values.yaml" "${TARGET_DIR}/environments/prod/values/"

replace_token() {
  local token="$1"
  local value="$2"
  local file="$3"
  python3 - "$token" "$value" "$file" <<'PY'
import sys
token, value, path = sys.argv[1], sys.argv[2], sys.argv[3]
data = open(path, encoding="utf-8").read()
data = data.replace(token, value)
open(path, "w", encoding="utf-8").write(data)
PY
}

while IFS= read -r file; do
  if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[DRY-RUN] replace tokens in ${file}"
  else
    replace_token "__PLATFORM_ENV_REPO_URL__" "${ENV_REPO_URL}" "${file}"
    replace_token "__PLATFORM_TEMPLATE_REPO_URL__" "${TEMPLATE_REPO_URL}" "${file}"
    replace_token "__GITHUB_ORG__" "${GITHUB_ORG}" "${file}"
    replace_token "__ARGOCD_NAMESPACE__" "${ARGOCD_NAMESPACE}" "${file}"
    replace_token "__CLUSTER_API_SERVER__" "${CLUSTER_API_SERVER}" "${file}"
  fi
done < <(grep -rl "__PLATFORM_ENV_REPO_URL__\|__PLATFORM_TEMPLATE_REPO_URL__\|__GITHUB_ORG__\|__ARGOCD_NAMESPACE__\|__CLUSTER_API_SERVER__" "${TARGET_DIR}" 2>/dev/null || true)

if [[ "${DRY_RUN}" == "true" ]]; then
  echo "GitOps bootstrap dry-run completed for ${TARGET_DIR}"
else
  echo "GitOps bootstrap completed in ${TARGET_DIR}"
fi
echo "Next steps:"
echo "  1) Commit files in env repo"
echo "  2) One-time: kubectl apply -n ${ARGOCD_NAMESPACE} -f argocd/platform-argocd-config-app.yaml"
echo "     (GitOps for AppProject; future edits to project-platform-services.yaml need only git push)"
echo "  3) One-time: kubectl apply -n ${ARGOCD_NAMESPACE} -f argocd/root-app.yaml"
echo "  4) Replace orders-api example with your real services"
