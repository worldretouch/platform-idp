# Port.io Golden Path — Setup Step-by-Step

Tài liệu này hướng dẫn triển khai Port.io cho dự án `platform-idp` theo đúng thứ tự,
đảm bảo mỗi bước chỉ phụ thuộc vào bước trước đó.

---

## Tổng quan kiến trúc

### System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  Port.io (SaaS)                                                             │
│                                                                             │
│  ┌─── Catalog (Blueprints & Entities) ────────────────────────────────────┐ │
│  │                                                                        │ │
│  │  _team ◀──owner── api_service ──▶ argocd_app ──▶ environment           │ │
│  │                                       │               │                │ │
│  │                                       ▼               ▼                │ │
│  │  k8s_pod ──▶ k8s_replicaSet ──▶ k8s_workload    k8s_cluster           │ │
│  │     │                                │               ▲                 │ │
│  │     ▼                                ▼               │                 │ │
│  │  k8s_node ◀──────────────────── k8s_namespace ───────┘                 │ │
│  │                                                                        │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│  ┌─ Self-service Actions ──┐  ┌─ Scorecards ──────┐  ┌─ Dashboard ──────┐ │
│  │ • Scaffold API (CREATE) │  │ • Prod Readiness   │  │ • Service Ovrvw  │ │
│  │ • Bootstrap Env (CREATE)│  │   (api_service)    │  │ • Deploy Status  │ │
│  │ • Scaffold GitOps (DAY2)│  │ • Deploy Health    │  │ • K8s Health     │ │
│  │ • Restart Service (DAY2)│  │   (argocd_app)     │  │ • Team View      │ │
│  │ • Rollback Service(DAY2)│  └────────────────────┘  └──────────────────┘ │
│  │ • Scale Service  (DAY2) │                                                │
│  └────────────┬────────────┘                                                │
│               │                                                             │
└───────────────┼─────────────────────────────────────────────────────────────┘
                │
    ┌───────────┴───────────────────────────────────────────────┐
    │           │                                               │
    ▼           │  dispatch workflow                 exporter    │
┌───────────────┴──────────────┐   ┌────────────────────────────┴─────────────┐
│  GitHub Actions              │   │  Kubernetes Cluster (DigitalOcean)        │
│  (repo: platform-idp)        │   │                                          │
│                              │   │  ┌──────────────────────────────────┐    │
│  Scaffold:                   │   │  │  Port K8s Exporter (Helm)        │    │
│  • scaffold-service.yml      │   │  │  sync: namespaces, nodes,        │    │
│  • bootstrap-env-repo.yml    │   │  │        workloads, replicasets,    │    │
│  • scaffold-env.yml          │   │  │        pods, ArgoCD apps         │───▶ Port
│  Day-2:                      │   │  └──────────────────────────────────┘    │
│  • restart-service.yml       │   │                                          │
│  • rollback-service.yml      │   │  ┌──────────────────────────────────┐    │
│  • scale-service.yml         │   │  │  ArgoCD                          │    │
│                              │   │  │  project: platform-services      │    │
└──────────────────────────────┘   │  │    ◀── platform-env (Git repo)   │    │
                                   │  └──────────┬───────────────────────┘    │
                                   │             │ deploy                     │
                                   │             ▼                            │
                                   │  ┌──────────────────────────────────┐    │
                                   │  │  Workloads                       │    │
                                   │  │  ├─ platform-dev   (4 services)  │    │
                                   │  │  ├─ platform-staging(4 services) │    │
                                   │  │  └─ platform-prod  (4 services)  │    │
                                   │  └──────────────────────────────────┘    │
                                   └──────────────────────────────────────────┘
```

### Data Flow

```
Developer ──▶ Port Self-service ──▶ GitHub Actions ──▶ platform-idp (template)
                                        │                      │
                                        ├──▶ New service repo  │
                                        └──▶ platform-env ─────┤
                                               │               │
                                         Git push         Helm chart
                                               │               │
                                               ▼               ▼
                                        ArgoCD sync ──▶ K8s Deployments
                                               │               │
                                               └───────┬───────┘
                                                       │
                                               Port K8s Exporter
                                                       │
                                                       ▼
                                               Port.io Catalog
                                        (realtime sync every ~30s)
```

### Blueprint Relationship Map

```
                          ┌──────────┐
                          │  _team   │
                          └────▲─────┘
                               │ owner
                          ┌────┴─────┐        ┌─────────────┐
                          │api_service│◀─svc──│ argocd_app  │
                          └──────────┘        └──┬──────┬───┘
                                                 │      │
                                            ns   │      │ env
                                                 ▼      ▼
┌──────────┐  Cluster   ┌──────────────┐    ┌────────────────┐
│k8s_cluster│◀──────────│k8s_namespace │    │  environment   │
└─────▲────┘            └──────▲───────┘    └────────┬───────┘
      │                        │ ns                  │ cluster
      │ Cluster          ┌─────┴───────┐             │
      ├─────────────────│ k8s_workload │◀── env ─────┘
      │                  └──────▲──────┘
      │                        │ owner
┌─────┴────┐             ┌─────┴──────────┐
│ k8s_node │◀── Node ───│ k8s_replicaSet │
└──────────┘             └──────▲─────────┘
                                │ replicaSet
                          ┌─────┴────┐
                          │ k8s_pod  │
                          └──────────┘
```

| Blueprint | Entities (ví dụ) | Source |
|---|---|---|
| `_team` | `dev_team`, `platform_team` | Manual / Port UI |
| `api_service` | `orders-api`, `catalog-api`, `payments-api`, `robo-api` | Scaffold workflow |
| `environment` | `dev`, `staging`, `prod` | Bootstrap workflow |
| `k8s_cluster` | `platform-cluster` | K8s Exporter |
| `k8s_namespace` | `argocd`, `platform-dev`, `platform-staging` | K8s Exporter |
| `k8s_node` | `platform-idp-node-pool-d63o0` | K8s Exporter |
| `k8s_workload` | `orders-api-Deployment-platform-dev` | K8s Exporter |
| `k8s_replicaSet` | `orders-api-d99bd6cdb-ReplicaSet-platform-dev` | K8s Exporter |
| `k8s_pod` | `orders-api-d99bd6cdb-pl9qv-platform-dev` | K8s Exporter |
| `argocd_app` | `orders-api-dev`, `catalog-api-staging` | K8s Exporter (CRD) |

---

## Giải thích các thành phần Port.io

| Thành phần | Là gì | Tác dụng | Ví dụ trong dự án này |
|---|---|---|---|
| **Blueprint** | Schema định nghĩa một loại entity | Quyết định fields, validation, relations của entity | `api_service`, `team` |
| **Entity** | Một bản ghi cụ thể trong Catalog | Đại diện cho 1 service/team thực tế | `orders-api`, `platform-team` |
| **Catalog** | Tập hợp tất cả entities | Inventory toàn bộ services, teams | Tra cứu "ai sở hữu service nào" |
| **Relation** | Liên kết giữa 2 blueprints | Gắn ownership, dependency | `api_service.team` → `team` |
| **Self-service Action** | Form + backend trigger | Cho dev tự tạo/sửa/xóa resource | "Scaffold API" button |
| **Action Run** | 1 lần chạy action | Theo dõi trạng thái, logs | Run #42: tạo `orders-api` |
| **Integration** | Kết nối hệ thống ngoài | Dispatch workflow, sync data | GitHub integration |
| **Scorecard** | Bộ tiêu chí đánh giá entity | Đo quality/compliance | "Production readiness" |
| **Exporter** | Agent chạy trong cluster, đẩy data vào Port | Sync realtime K8s/ArgoCD state | Port K8s Exporter (bao gồm cả ArgoCD CRD) |
| **Mirror Property** | Property lấy từ entity liên kết | Hiển thị data xuyên blueprint không duplicate | Service hiển thị cluster region từ relation |

---

## Step-by-step Setup

### Step 0 — Prerequisites

Trước khi bắt đầu, đảm bảo:

- [ ] Có tài khoản Port.io (free tier đủ để bắt đầu).
- [ ] Repo `platform-idp` đã push lên GitHub org `worldretouch`.
- [ ] File `.github/workflows/scaffold-service.yml` đã có trong repo `platform-idp`.
- [ ] GitHub PAT (`GH_ORG_TOKEN`) đã tạo với quyền `repo` + `read:org`.
- [ ] Secret `GH_ORG_TOKEN` đã set trong repo `platform-idp` trên GitHub.
- [ ] Có Port Client ID + Client Secret (lấy từ Port Settings → Credentials).
- [ ] Secret `PORT_CLIENT_ID` và `PORT_CLIENT_SECRET` đã set trong repo `platform-idp`.

---

### Step 1 — Cài đặt GitHub Integration trong Port

**Mục đích:** Cho phép Port dispatch workflow và đọc repo metadata.

1. Vào Port → **Settings** → **Integrations** → **GitHub**.
2. Cài GitHub App của Port vào org `worldretouch`.
3. Chọn repo `platform-idp` (và các repo khác nếu muốn sync catalog).
4. Ghi nhận `installationId` (thường là `github-ocean` nếu dùng Ocean integration).

**Verify:** Trong Port → Integrations → GitHub hiển thị status "Connected".

---

### Step 2 — Bootstrap Environment Repo (`platform-env`)

**Mục đích:** Tạo repo GitOps `platform-env` với cấu trúc ArgoCD (argocd/, environments/dev|staging|prod) — đây là nơi ArgoCD đọc state deploy cho tất cả services.

**Khi nào cần:** Chỉ chạy **1 lần** khi bắt đầu dự án, trước khi scaffold bất kỳ service nào.

#### Cách 1 — Qua Port Self-service (khuyến nghị)

1. Đăng ký action vào Port:

```bash
curl -X POST "https://api.port.io/v1/actions" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @port/actions/bootstrap-env-repo.json
```

2. Vào Port → Self-service → **"Bootstrap Environment Repo"**
3. Điền form:
   - env_repo_name: `platform-env`
   - github_org: `worldretouch`
   - repo_visibility: `private`
4. Bấm **Execute**

#### Cách 2 — Qua CLI (local)

```bash
# Tạo repo trên GitHub trước
gh repo create worldretouch/platform-env --private

# Clone repo rỗng
git clone https://github.com/worldretouch/platform-env.git ../platform-env

# Bootstrap cấu trúc
bash shared/gitops/bootstrap-env-repo.sh \
  --target-dir ../platform-env \
  --env-repo-url https://github.com/worldretouch/platform-env.git \
  --template-repo-url https://github.com/worldretouch/platform-idp.git \
  --github-org worldretouch

# Push
cd ../platform-env && git add . && git commit -m "feat: bootstrap env repo" && git push
```

**Kết quả:**

```
platform-env/
├── .github/workflows/
│   └── promote-to-env.yml          ← workflow promote image tag (staging/prod)
├── argocd/
│   ├── root-app.yaml
│   ├── project-platform-services.yaml
│   └── platform-argocd-config-app.yaml
└── environments/
    ├── dev/
    │   ├── apps/orders-api.yaml
    │   └── values/orders-api.values.yaml
    ├── staging/
    │   ├── apps/orders-api.yaml
    │   └── values/orders-api.values.yaml
    └── prod/
        ├── apps/orders-api.yaml
        └── values/orders-api.values.yaml
```

**Nếu chạy qua Port (Cách 1)**, workflow còn tự động:
- Tạo blueprint `environment` trong Port Catalog
- Tạo 3 entities: `dev`, `staging`, `prod` (với `k8s_namespace: platform-{env}`, `argocd_project: platform-services`)

→ Step 12 (Blueprint `environment`) sẽ được skip vì đã hoàn thành ở đây.

**Verify:** Repo `worldretouch/platform-env` tồn tại trên GitHub với cấu trúc trên. Nếu dùng Cách 1, kiểm tra Port Catalog → `environment` → thấy 3 entities (dev/staging/prod).

**Sau khi bootstrap**, cần apply 1 lần vào cluster:

```bash
kubectl apply -n argocd -f argocd/platform-argocd-config-app.yaml
kubectl apply -n argocd -f argocd/root-app.yaml
```

---

### Step 3 — Tạo Blueprint `team`

**Mục đích:** Định nghĩa schema cho team, làm nền cho relation ownership.

**Cách tạo:** Port UI → **Builder** → **Blueprints** → **New Blueprint**, hoặc qua API:

```bash
curl -X POST "https://api.getport.io/v1/blueprints" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "identifier": "team",
  "title": "Team",
  "icon": "Users",
  "description": "Team owning services",
  "schema": {
    "properties": {
      "slug": {
        "type": "string",
        "title": "Team Slug",
        "pattern": "^[a-z0-9]+(-[a-z0-9]+)*$"
      },
      "display_name": {
        "type": "string",
        "title": "Display Name"
      }
    },
    "required": ["slug", "display_name"]
  },
  "relations": {}
}
EOF
```

**Verify:** Blueprint `team` xuất hiện trong Builder.

---

### Step 4 — Tạo Blueprint `api_service` (với relation tới `team`)

**Mục đích:** Định nghĩa schema cho API service, gắn ownership vào team.

```bash
curl -X POST "https://api.getport.io/v1/blueprints" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "identifier": "api_service",
  "title": "API Service",
  "icon": "Microservice",
  "description": "API service scaffolded from platform template",
  "schema": {
    "properties": {
      "service_name": {
        "type": "string",
        "title": "Service Name",
        "pattern": "^[a-z0-9]+(-[a-z0-9]+)*$"
      },
      "runtime": {
        "type": "string",
        "title": "Runtime",
        "enum": ["go", "node", "python", "rails"]
      },
      "domain": {
        "type": "string",
        "title": "Domain"
      },
      "owner": {
        "type": "string",
        "title": "Owner Team Slug"
      },
      "repo_url": {
        "type": "string",
        "title": "Repository URL",
        "format": "url"
      },
      "platform_template_version": {
        "type": "string",
        "title": "Template Version"
      },
      "k8s_namespace": {
        "type": "string",
        "title": "Kubernetes Namespace"
      },
      "has_database": {
        "type": "boolean",
        "title": "Has Database",
        "default": false
      },
      "has_redis": {
        "type": "boolean",
        "title": "Has Redis",
        "default": false
      }
    },
    "required": ["service_name", "runtime", "domain", "owner"]
  },
  "relations": {
    "team": {
      "title": "Team",
      "target": "team",
      "required": false,
      "many": false
    }
  }
}
EOF
```

**Verify:** Blueprint `api_service` xuất hiện trong Builder, có relation `team` trỏ tới blueprint `team`.

---

### Step 5 — Tạo Team Entities

**Mục đích:** Tạo các team thực tế để relation hoạt động.

```bash
# Tạo team "platform-team"
curl -X POST "https://api.getport.io/v1/blueprints/team/entities" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "platform-team",
    "title": "Platform Team",
    "properties": {
      "slug": "platform-team",
      "display_name": "Platform Team"
    }
  }'

# Tạo team "dev-team"
curl -X POST "https://api.getport.io/v1/blueprints/team/entities" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "dev-team",
    "title": "Dev Team",
    "properties": {
      "slug": "dev-team",
      "display_name": "Dev Team"
    }
  }'
```

**Verify:** Catalog → Team → thấy 2 entities.

---

### Step 6 — Tạo Self-service Action "Scaffold API"

**Mục đích:** Cho phép dev bấm nút tạo service mới, Port dispatch workflow tới GitHub.

Dùng file đã có trong repo: `port/actions/scaffold-service.json`.

```bash
curl -X POST "https://api.getport.io/v1/actions" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @port/actions/scaffold-service.json
```

**Verify:** Port → Self-service → thấy action "Scaffold API" với form đầy đủ fields.

---

### Step 7 — Test end-to-end: Scaffold 1 service

**Mục đích:** Kiểm tra toàn bộ luồng Port → GitHub Actions → repo mới.

1. Vào Port → Self-service → "Scaffold API".
2. Điền form:
   - service_name: `demo-api`
   - runtime: `python`
   - domain: `demo`
   - owner: `platform-team`
   - (để mặc định các field còn lại)
3. Bấm **Execute**.

**Kiểm tra:**

| Tiêu chí | Kỳ vọng |
|---|---|
| Port action run | Status = SUCCESS |
| Port action logs | Hiển thị từng bước: create repo, scaffold, push |
| GitHub repo `worldretouch/demo-api` | Tồn tại, có code scaffold |
| `demo-api/service.yaml` | Có đúng `service_name: demo-api`, `runtime: python`, `owner: platform-team` |
| Port Catalog | Entity `demo-api` xuất hiện trong blueprint `api_service` |

**Dọn dẹp sau test:** Xóa repo `demo-api` trên GitHub và entity trong Port nếu chỉ là test.

---

### Step 8 — Tạo Self-service Action "Scaffold GitOps" (platform-env)

**Mục đích:** Sau khi tạo service repo (Step 6–7), cần tạo ArgoCD Application + Helm values trong `platform-env` để service deploy được qua GitOps.

**Prerequisite:** Service entity đã tồn tại trong Catalog (Step 7 hoàn thành).

#### 7.1 — Workflow `scaffold-env.yml` (đã có trong repo)

File: `.github/workflows/scaffold-env.yml`

Luồng:
1. Checkout `platform-idp` (để dùng `make scaffold-env`)
2. Clone `platform-env`
3. Chạy `make scaffold-env SERVICE_NAME=... ENV_REPO_DIR=/tmp/platform-env`
   - Copy `orders-api.yaml` → `{service_name}.yaml` trong `apps/` cho mỗi env (dev/staging/prod)
   - Copy `orders-api.values.yaml` → `{service_name}.values.yaml` trong `values/` cho mỗi env
   - Sed replace `orders-api` → `{service_name}` trong mỗi file
4. Tạo branch + mở PR vào `platform-env`
5. Báo status về Port

#### 7.2 — Port action payload (đã có trong repo)

File: `port/actions/scaffold-env.json`

- **Operation:** `DAY-2` (chỉ chạy trên entity đã tồn tại)
- **Blueprint:** `api_service`
- **Không cần user input** — lấy `service_name` từ entity properties
- Dispatch workflow `scaffold-env.yml`

#### 7.3 — Đăng ký action vào Port

```bash
curl -X POST "https://api.port.io/v1/actions" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @port/actions/scaffold-env.json
```

#### 7.4 — Test

1. Vào Catalog → chọn entity service (ví dụ `orders-api`)
2. Bấm action **"Scaffold GitOps"**
3. Kiểm tra:

| Tiêu chí | Kỳ vọng |
|---|---|
| Port action run | Status = SUCCESS |
| `platform-env` repo | Có PR mới với branch `scaffold/{service_name}-gitops` |
| PR contents | `apps/{service_name}.yaml` + `values/{service_name}.values.yaml` cho dev/staging/prod |
| Merge PR | ArgoCD tự sync Application mới |

**Lưu ý:** `GH_ORG_TOKEN` cần quyền push + tạo PR vào repo `platform-env`.

---

### Step 9 — Scaffold 4 services thật

Sau khi test thành công, chạy action cho 4 services:

| service_name | runtime | domain | owner |
|---|---|---|---|
| `orders-api` | `go` | `orders` | `platform-team` |
| `catalog-api` | `python` | `catalog` | `dev-team` |
| `payments-api` | `node` | `payments` | `dev-team` |
| `robo-api` | `rails` | `automation` | `platform-team` |

Sau đó chạy action "Scaffold GitOps" cho từng service (nếu đã làm Step 8).

---

### Step 10 — Tích hợp Kubernetes Exporter

**Mục đích:** Tự động đưa toàn bộ workload K8s (Deployment, Pod, Service, Namespace) vào Port Catalog để xem realtime service nào đang chạy, crash, hay pending.

#### 10.1 — Tạo Blueprints + Cluster Entity

Blueprint JSON files nằm trong `port/blueprints/`:

| File | Blueprint | Relation |
|---|---|---|
| `port/blueprints/api-service.json` | `api_service` | → `_team` |
| `port/blueprints/k8s-cluster.json` | `k8s_cluster` | — |
| `port/blueprints/k8s-namespace.json` | `k8s_namespace` | → `k8s_cluster` |
| `port/blueprints/k8s-workload.json` | `k8s_workload` | → `k8s_namespace`, → `api_service`, → `environment` |
| `port/blueprints/k8s-replicaset.json` | `k8s_replicaSet` | → `k8s_workload` |
| `port/blueprints/k8s-pod.json` | `k8s_pod` | → `k8s_replicaSet`, → `k8s_node` |
| `port/blueprints/argocd-app.json` | `argocd_app` | → `k8s_namespace`, → `api_service`, → `environment` |

**Chạy script để tạo tất cả blueprints + cluster entity (idempotent, auto-detect cluster info):**

```bash
PORT_ACCESS_TOKEN="$ACCESS_TOKEN" bash port/setup-blueprints.sh \
  --provider digitalocean \
  --region sgp1
```

Script tự động:
1. Tạo/update 8 blueprints theo đúng thứ tự dependency (POST → nếu 409 → PATCH)
2. Auto-detect K8s version và API server URL từ `kubectl`
3. Tạo entity `platform-cluster` trong blueprint `k8s_cluster`

> Tùy chỉnh: `--cluster-name`, `--cluster-title`, `--provider`, `--region`, `--k8s-version`, `--api-server-url`, `--skip-entity`

#### 10.2 — Cài Port K8s Exporter

Cài theo [Port docs chuẩn](https://docs.port.io/build-your-software-catalog/sync-data-to-catalog/kubernetes-stack/kubernetes/):

```bash
helm repo add port-labs https://port-labs.github.io/helm-charts
helm repo update

helm upgrade --install platform-cluster port-labs/port-k8s-exporter \
  --create-namespace --namespace port-k8s-exporter \
  --set secret.secrets.portClientId="$PORT_CLIENT_ID" \
  --set secret.secrets.portClientSecret="$PORT_CLIENT_SECRET" \
  --set portBaseUrl="https://api.port.io" \
  --set stateKey="platform-cluster" \
  --set eventListener.type="POLLING" \
  --set "extraEnv[0].name=CLUSTER_NAME" \
  --set "extraEnv[0].value=platform-cluster"
```

Lệnh này dùng `createDefaultResources: true` (mặc định) — Port tự tạo default blueprints và resource mappings.

**Quan trọng:** Sau khi cài, vào Port UI → **Settings → Data Sources** → chọn integration → bật **"Create missing related entities"** để tránh domino failure khi entity phụ thuộc chưa kịp tạo.

**Nếu muốn custom config (chỉ sync `platform-*` namespaces):**

Dùng `--set-file configMap.config=port/exporter/config.yaml` thay cho `createDefaultResources`:

```bash
helm upgrade --install platform-cluster port-labs/port-k8s-exporter \
  --create-namespace --namespace port-k8s-exporter \
  --set secret.secrets.portClientId="$PORT_CLIENT_ID" \
  --set secret.secrets.portClientSecret="$PORT_CLIENT_SECRET" \
  --set portBaseUrl="https://api.port.io" \
  --set stateKey="platform-cluster" \
  --set createDefaultResources=false \
  --set eventListener.type="POLLING" \
  --set "extraEnv[0].name=CLUSTER_NAME" \
  --set "extraEnv[0].value=platform-cluster" \
  --set-file configMap.config=port/exporter/config.yaml
```

**Verify:** Catalog → `k8s_workload` → thấy các Deployment/StatefulSet. Property `is_healthy` = `true` nếu available == desired replicas.

**Upgrade (khi thay đổi config):**

```bash
helm upgrade platform-cluster port-labs/port-k8s-exporter \
  --namespace port-k8s-exporter \
  --set secret.secrets.portClientId="$PORT_CLIENT_ID" \
  --set secret.secrets.portClientSecret="$PORT_CLIENT_SECRET" \
  --set portBaseUrl="https://api.port.io" \
  --set stateKey="platform-cluster" \
  --set eventListener.type="POLLING" \
  --set "extraEnv[0].name=CLUSTER_NAME" \
  --set "extraEnv[0].value=platform-cluster"
```

---

### Step 11 — Tích hợp ArgoCD

**Mục đích:** Xem trạng thái sync, health của từng ArgoCD Application ngay trong Port — biết service nào đang Synced, OutOfSync, Degraded, hay Missing.

#### 10.1 — Tạo Blueprint `argocd_app`

```bash
curl -X POST "https://api.getport.io/v1/blueprints" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "identifier": "argocd_app",
  "title": "ArgoCD Application",
  "icon": "Argo",
  "schema": {
    "properties": {
      "sync_status": {
        "type": "string",
        "title": "Sync Status",
        "enum": ["Synced", "OutOfSync", "Unknown"],
        "enumColors": {
          "Synced": "green",
          "OutOfSync": "red",
          "Unknown": "yellow"
        }
      },
      "health_status": {
        "type": "string",
        "title": "Health Status",
        "enum": ["Healthy", "Degraded", "Progressing", "Suspended", "Missing", "Unknown"],
        "enumColors": {
          "Healthy": "green",
          "Degraded": "red",
          "Progressing": "yellow",
          "Suspended": "lightGray",
          "Missing": "red",
          "Unknown": "yellow"
        }
      },
      "git_repo": {
        "type": "string",
        "title": "Git Repo URL",
        "format": "url"
      },
      "git_path": {
        "type": "string",
        "title": "Git Path"
      },
      "target_revision": {
        "type": "string",
        "title": "Target Revision"
      },
      "destination_namespace": {
        "type": "string",
        "title": "Destination Namespace"
      },
      "destination_server": {
        "type": "string",
        "title": "Destination Server"
      },
      "created_at": {
        "type": "string",
        "title": "Created At",
        "format": "date-time"
      },
      "auto_sync": {
        "type": "boolean",
        "title": "Auto Sync Enabled"
      }
    },
    "required": []
  },
  "relations": {
    "namespace": {
      "title": "Namespace",
      "target": "k8s_namespace",
      "required": false,
      "many": false
    },
    "service": {
      "title": "API Service",
      "target": "api_service",
      "required": false,
      "many": false
    }
  }
}
EOF
```

#### 10.2 — Tích hợp ArgoCD qua K8s Exporter

Thay vì cài exporter riêng, ta tận dụng K8s Exporter đã cài ở Step 10 để sync ArgoCD Applications (CRD).

Blueprint `argocd_app` đã được tạo ở bước trên. Mapping ArgoCD Applications nằm trong `port/exporter/config.yaml`:

```yaml
  # --- ArgoCD Applications ---
  - kind: argoproj.io/v1alpha1/applications
    selector:
      query: '.spec.project == "platform-services" and (.metadata.name | test("^platform-") | not)'
    port:
      entity:
        mappings:
          - identifier: .metadata.name + "-" + env.CLUSTER_NAME
            blueprint: '"argocd_app"'
            title: .metadata.name
            properties:
              sync_status: .status.sync.status
              health_status: .status.health.status
              git_repo: (.spec.sources[0].repoURL // .spec.source.repoURL)
              git_path: (.spec.sources[0].path // .spec.source.path)
              target_revision: (.spec.sources[0].targetRevision // .spec.source.targetRevision)
              destination_namespace: .spec.destination.namespace
              destination_server: .spec.destination.server
              created_at: .metadata.creationTimestamp
              auto_sync: (.spec.syncPolicy.automated != null)
            relations:
              namespace: .spec.destination.namespace + "-" + env.CLUSTER_NAME
              service: .metadata.name | sub("-dev$"; "") | sub("-staging$"; "") | sub("-prod$"; "")
              environment: .metadata.name | split("-") | .[-1]
```

Sau khi update config, chạy `helm upgrade` (xem Step 10) để apply.

**Verify:** Catalog → argocd_app → thấy entities như `orders-api-dev-platform-cluster`, `orders-api-staging-platform-cluster`, `orders-api-prod-platform-cluster` với sync/health status realtime.

---

### Step 12 — Blueprint `environment`

> **Nếu đã chạy Step 2 qua Port Self-service:** Blueprint `environment` và 3 entities (dev/staging/prod) đã được tạo tự động. Bước này chỉ cần khi:
> - Bạn dùng CLI (Cách 2) ở Step 2
> - Bạn muốn bổ sung relation `cluster` (sau khi Step 10 tạo `k8s_cluster` blueprint)

**Mục đích:** Model hóa các môi trường (dev/staging/prod) để liên kết service → environment → cluster, và dùng trong dashboard + action.

**Tạo blueprint (nếu chưa tồn tại):**

```bash
curl -X POST "https://api.getport.io/v1/blueprints" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d @- <<'EOF'
{
  "identifier": "environment",
  "title": "Environment",
  "icon": "Environment",
  "schema": {
    "properties": {
      "type": {
        "type": "string",
        "title": "Environment Type",
        "enum": ["dev", "staging", "prod"],
        "enumColors": {
          "dev": "turquoise",
          "staging": "yellow",
          "prod": "red"
        }
      },
      "k8s_namespace": {
        "type": "string",
        "title": "Kubernetes Namespace"
      },
      "argocd_project": {
        "type": "string",
        "title": "ArgoCD Project"
      }
    },
    "required": ["type", "k8s_namespace"]
  },
  "relations": {}
}
EOF
```

**Bổ sung relation `cluster` (sau khi đã có blueprint `k8s_cluster` từ Step 10):**

```bash
curl -X PATCH "https://api.getport.io/v1/blueprints/environment" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "relations": {
      "cluster": {
        "title": "Cluster",
        "target": "k8s_cluster",
        "required": false,
        "many": false
      }
    }
  }'
```

**Tạo entities (nếu chưa tồn tại):**

```bash
for ENV in dev staging prod; do
  curl -X POST "https://api.getport.io/v1/blueprints/environment/entities?upsert=true" \
    -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"identifier\": \"${ENV}\",
      \"title\": \"${ENV}\",
      \"properties\": {
        \"type\": \"${ENV}\",
        \"k8s_namespace\": \"platform-${ENV}\",
        \"argocd_project\": \"platform-services\"
      }
    }"
done
```

---

### Step 13 — Thêm relation `environment` vào `argocd_app` và `k8s_workload`

Sau khi đã có blueprint `environment`, bổ sung relation:

```bash
# Thêm relation environment vào argocd_app
curl -X PATCH "https://api.getport.io/v1/blueprints/argocd_app" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "relations": {
      "namespace": { "title": "Namespace", "target": "k8s_namespace", "required": false, "many": false },
      "service": { "title": "API Service", "target": "api_service", "required": false, "many": false },
      "environment": { "title": "Environment", "target": "environment", "required": false, "many": false }
    }
  }'

# Thêm relation environment vào k8s_workload
curl -X PATCH "https://api.getport.io/v1/blueprints/k8s_workload" \
  -H "Authorization: Bearer $PORT_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "relations": {
      "namespace": { "title": "Namespace", "target": "k8s_namespace", "required": false, "many": false },
      "service": { "title": "API Service", "target": "api_service", "required": false, "many": false },
      "environment": { "title": "Environment", "target": "environment", "required": false, "many": false }
    }
  }'
```

Cập nhật mapping trong exporter values để set `environment` relation dựa trên namespace:

```yaml
# Trong k8s-exporter-values.yaml, thêm vào mapping của deployments:
relations:
  namespace: .metadata.namespace
  service: .metadata.name
  environment: .metadata.namespace | sub("^platform-"; "")

# Trong argocd-exporter-values.yaml, thêm vào mapping:
relations:
  namespace: .spec.destination.namespace
  service: .metadata.name | sub("-dev$"; "") | sub("-staging$"; "") | sub("-prod$"; "")
  environment: .metadata.name | sub("^.*-"; "")
```

---

### Step 14 — Self-service Actions cho Day-2 Operations

**Mục đích:** Cho dev tự rollback, restart, scale service mà không cần ticket DevOps.

#### 13.1 — Action: Restart Service

Tạo workflow `.github/workflows/restart-service.yml`:

```yaml
name: Restart Service
on:
  workflow_dispatch:
    inputs:
      port_context:
        required: true
        type: string
      service_name:
        required: true
        type: string
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  restart:
    runs-on: ubuntu-latest
    steps:
      - name: Configure kubectl
        uses: azure/k8s-set-context@v4
        with:
          kubeconfig: ${{ secrets.KUBECONFIG }}

      - name: Rollout restart
        run: |
          kubectl rollout restart deployment/${{ inputs.service_name }} \
            -n platform-${{ inputs.environment }}
          kubectl rollout status deployment/${{ inputs.service_name }} \
            -n platform-${{ inputs.environment }} --timeout=120s
```

Port action payload:

```json
{
  "identifier": "restart_service",
  "title": "Restart Service",
  "icon": "Argo",
  "trigger": {
    "type": "self-service",
    "operation": "DAY-2",
    "blueprintIdentifier": "api_service",
    "userInputs": {
      "properties": {
        "environment": {
          "type": "string",
          "title": "Environment",
          "enum": ["dev", "staging", "prod"],
          "default": "dev"
        }
      },
      "required": ["environment"]
    }
  },
  "invocationMethod": {
    "type": "GITHUB",
    "org": "worldretouch",
    "repo": "platform-idp",
    "workflow": "restart-service.yml",
    "workflowInputs": {
      "service_name": "{{ .entity.properties.service_name }}",
      "environment": "{{ .inputs.environment }}"
    },
    "reportWorkflowStatus": true
  },
  "requiredApproval": false
}
```

#### 13.2 — Action: Rollback (ArgoCD)

```yaml
# .github/workflows/rollback-service.yml
name: Rollback Service
on:
  workflow_dispatch:
    inputs:
      port_context:
        required: true
        type: string
      service_name:
        required: true
        type: string
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Configure kubectl
        uses: azure/k8s-set-context@v4
        with:
          kubeconfig: ${{ secrets.KUBECONFIG }}

      - name: Rollback to previous revision
        run: |
          kubectl rollout undo deployment/${{ inputs.service_name }} \
            -n platform-${{ inputs.environment }}
          kubectl rollout status deployment/${{ inputs.service_name }} \
            -n platform-${{ inputs.environment }} --timeout=120s
```

#### 13.3 — Action: Scale Service

```yaml
# .github/workflows/scale-service.yml
name: Scale Service
on:
  workflow_dispatch:
    inputs:
      port_context:
        required: true
        type: string
      service_name:
        required: true
        type: string
      environment:
        required: true
        type: choice
        options: [dev, staging, prod]
      replicas:
        required: true
        type: string

jobs:
  scale:
    runs-on: ubuntu-latest
    steps:
      - name: Configure kubectl
        uses: azure/k8s-set-context@v4
        with:
          kubeconfig: ${{ secrets.KUBECONFIG }}

      - name: Scale deployment
        run: |
          kubectl scale deployment/${{ inputs.service_name }} \
            --replicas=${{ inputs.replicas }} \
            -n platform-${{ inputs.environment }}
```

---

### Step 15 — Scorecard: Production Readiness

**Mục đích:** Đánh giá mỗi service đã sẵn sàng production chưa.

Tạo Scorecard trên blueprint `api_service`:

```json
{
  "identifier": "production_readiness",
  "title": "Production Readiness",
  "levels": [
    { "color": "red", "title": "Basic" },
    { "color": "yellow", "title": "Silver" },
    { "color": "green", "title": "Gold" }
  ],
  "rules": [
    {
      "identifier": "has_owner",
      "title": "Has Owner",
      "level": "Silver",
      "query": { "combinator": "and", "conditions": [{ "property": "owner", "operator": "isNotEmpty" }] }
    },
    {
      "identifier": "has_repo",
      "title": "Has Repository URL",
      "level": "Silver",
      "query": { "combinator": "and", "conditions": [{ "property": "repo_url", "operator": "isNotEmpty" }] }
    },
    {
      "identifier": "has_database_declared",
      "title": "Dependencies Declared",
      "level": "Gold",
      "query": { "combinator": "and", "conditions": [{ "property": "has_database", "operator": "isNotEmpty" }] }
    }
  ]
}
```

Tạo Scorecard trên blueprint `argocd_app`:

```json
{
  "identifier": "deployment_health",
  "title": "Deployment Health",
  "levels": [
    { "color": "red", "title": "Critical" },
    { "color": "yellow", "title": "Warning" },
    { "color": "green", "title": "Healthy" }
  ],
  "rules": [
    {
      "identifier": "is_synced",
      "title": "Synced with Git",
      "level": "Warning",
      "query": { "combinator": "and", "conditions": [{ "property": "sync_status", "operator": "=", "value": "Synced" }] }
    },
    {
      "identifier": "is_healthy",
      "title": "Health OK",
      "level": "Warning",
      "query": { "combinator": "and", "conditions": [{ "property": "health_status", "operator": "=", "value": "Healthy" }] }
    },
    {
      "identifier": "auto_sync_on",
      "title": "Auto Sync Enabled",
      "level": "Healthy",
      "query": { "combinator": "and", "conditions": [{ "property": "auto_sync", "operator": "=", "value": true }] }
    }
  ]
}
```

---

### Step 16 — Dashboard

**Mục đích:** Tổng quan nhanh tình trạng toàn bộ platform.

Dashboard configs nằm trong `port/dashboards/`, mỗi file = 1 dashboard page.

**Chạy script để tạo/update tất cả dashboards (idempotent):**

```bash
PORT_ACCESS_TOKEN="$ACCESS_TOKEN" bash port/setup-dashboards.sh
```

Script tự động:
1. Đọc tất cả `port/dashboards/*.json`
2. Stringify widget config → POST `/v1/pages` (nếu 409 → PATCH update)

#### 16.1 — Service Overview (`port/dashboards/service-overview.json`)

| Widget | Type | Mô tả |
|---|---|---|
| Total Services | number-chart | Đếm tổng `api_service` entities |
| Missing Owner | number-chart | Services chưa có team owner |
| With Database | number-chart | Services có `has_database = true` |
| Services by Runtime | pie-chart | Phân bố theo `runtime` (go/node/python/rails) |
| Services by Domain | pie-chart | Phân bố theo `domain` |
| All Services | table | Bảng toàn bộ services với properties + relations |

#### 16.2 — Deployment Status (`port/dashboards/deployment-status.json`)

| Widget | Type | Mô tả |
|---|---|---|
| Total ArgoCD Apps | number-chart | Tổng `argocd_app` entities |
| Synced | number-chart | Apps có `sync_status = Synced` |
| OutOfSync | number-chart | Apps có `sync_status = OutOfSync` |
| Degraded | number-chart | Apps có `health_status = Degraded` |
| Apps by Health Status | pie-chart | Phân bố theo `health_status` |
| Apps by Environment | pie-chart | Phân bố theo relation `environment` |
| All ArgoCD Applications | table | Bảng toàn bộ ArgoCD apps |

#### 16.3 — Kubernetes Health (`port/dashboards/k8s-health.json`)

| Widget | Type | Mô tả |
|---|---|---|
| Total Workloads | number-chart | Tổng `k8s_workload` entities |
| Healthy | number-chart | Workloads có `isHealthy = Healthy` |
| Unhealthy | number-chart | Workloads có `isHealthy != Healthy` |
| Total Pods | number-chart | Tổng `k8s_pod` entities |
| Workloads by Namespace | pie-chart | Phân bố theo relation `Namespace` |
| Workloads by Kind | pie-chart | Phân bố theo `kind` (Deployment/StatefulSet/DaemonSet) |
| All Workloads | table | Bảng toàn bộ workloads |
| All Pods | table | Bảng toàn bộ pods |

#### 16.4 — Team View (`port/dashboards/team-view.json`)

| Widget | Type | Mô tả |
|---|---|---|
| Total Teams | number-chart | Tổng `_team` entities |
| Services with Owner | number-chart | Services có owner |
| Unowned Services | number-chart | Services chưa có owner |
| Services by Team | pie-chart | Phân bố services theo relation `team` |
| Services by Runtime | pie-chart | Phân bố runtime theo team view |
| All Teams | table | Bảng toàn bộ teams |
| All Services (with Owner) | table | Bảng services kèm thông tin owner |

---

## Thứ tự tóm tắt

```
Phase A — Foundation (Infra + Catalog + Self-service)
──────────────────────────────────────────────────────
Step 0   Prerequisites (secrets, token, repo)
  │
Step 1   GitHub Integration
  │
Step 2   Bootstrap Environment Repo (platform-env) ← 1 lần duy nhất
  │
Step 3   Blueprint: team
  │
Step 4   Blueprint: api_service (relation → team)
  │
Step 5   Team entities
  │
Step 6   Action: Scaffold API (code repo + entity)
  │
Step 7   Test end-to-end (1 demo service)
  │
Step 8   Action: Scaffold GitOps (platform-env)
  │
Step 9   Scaffold 4 services thật

Phase B — Observability (K8s + ArgoCD)
──────────────────────────────────────────────
Step 10  K8s Exporter (blueprints + helm install)
  │
Step 11  ArgoCD via K8s Exporter (blueprint + CRD mapping)
  │
Step 12  Blueprint: environment (auto nếu Step 2 qua Port, manual nếu CLI)
  │
Step 13  Wire relations: argocd_app/k8s_workload → environment + cluster

Phase C — Day-2 Operations + Quality
──────────────────────────────────────────────
Step 14  Self-service: Restart / Rollback / Scale
  │
Step 15  Scorecards (production readiness + deployment health)
  │
Step 16  Dashboard (service overview + deployment + k8s + team)
```

---

## Relationship Map (tổng thể)

> Chi tiết xem phần [Blueprint Relationship Map](#blueprint-relationship-map) ở đầu tài liệu.

```
_team ◀── owner ── api_service
                       │
                       ├──svc──▶ argocd_app ──env──▶ environment ──cluster──▶ k8s_cluster
                       │              │                                          ▲
                       │              │ ns                                       │
                       │              ▼                                          │
                       └──env──▶ k8s_workload ──ns──▶ k8s_namespace ──Cluster───┘
                                     ▲
                                     │ owner
                        k8s_pod ──▶ k8s_replicaSet
                          │
                          └──Node──▶ k8s_node ──Cluster──▶ k8s_cluster
```

---

## Files liên quan trong repo

| File | Mục đích |
|---|---|
| `.github/workflows/scaffold-service.yml` | Workflow tạo repo code từ template |
| `.github/workflows/bootstrap-env-repo.yml` | Workflow bootstrap repo platform-env + tạo blueprint/entities `environment` |
| `.github/workflows/scaffold-env.yml` | Workflow tạo GitOps manifests cho 1 service |
| `shared/gitops/bootstrap-env-repo.sh` | Script bootstrap cấu trúc platform-env |
| `shared/gitops/promote-to-env.example.yml` | Template workflow promote image tag (copy vào platform-env khi bootstrap) |
| `.github/workflows/restart-service.yml` | Workflow restart deployment (Day-2) |
| `.github/workflows/rollback-service.yml` | Workflow rollback deployment (Day-2) |
| `.github/workflows/scale-service.yml` | Workflow scale deployment (Day-2) |
| `port/blueprints/api-service.json` | Blueprint API Service |
| `port/blueprints/k8s-cluster.json` | Blueprint K8s Cluster |
| `port/blueprints/k8s-namespace.json` | Blueprint K8s Namespace |
| `port/blueprints/k8s-workload.json` | Blueprint K8s Workload |
| `port/blueprints/k8s-replicaset.json` | Blueprint K8s ReplicaSet |
| `port/blueprints/k8s-pod.json` | Blueprint K8s Pod |
| `port/blueprints/argocd-app.json` | Blueprint ArgoCD Application |
| `port/actions/bootstrap-env-repo.json` | Port action payload cho "Bootstrap Environment Repo" |
| `port/actions/scaffold-service.json` | Port action payload cho "Scaffold API" |
| `port/actions/scaffold-env.json` | Port action payload cho "Scaffold GitOps" |
| `port/actions/restart-service.json` | Port action payload cho "Restart Service" |
| `port/actions/rollback-service.json` | Port action payload cho "Rollback Service" |
| `port/actions/scale-service.json` | Port action payload cho "Scale Service" |
| `port/exporter/values.yaml` | Helm chart values cho Port K8s Exporter |
| `port/exporter/config.yaml` | Exporter resource mappings (namespaces, nodes, workloads, replicasets, pods, ArgoCD apps) |
| `port/dashboards/service-overview.json` | Dashboard: Service Overview (runtime, owner, domain) |
| `port/dashboards/deployment-status.json` | Dashboard: Deployment Status (ArgoCD sync/health) |
| `port/dashboards/k8s-health.json` | Dashboard: Kubernetes Health (workloads, pods, nodes) |
| `port/dashboards/team-view.json` | Dashboard: Team View (ownership, services per team) |
| `port/setup-blueprints.sh` | Script tạo/update tất cả blueprints + cluster entity (idempotent) |
| `port/setup-dashboards.sh` | Script tạo/update tất cả dashboard pages (idempotent) |
| `Makefile` (target `scaffold`) | Logic scaffold code |
| `Makefile` (target `scaffold-env`) | Logic scaffold GitOps manifests |
| `base-template/` | Shared base cho mọi service |
| `starters/{runtime}-api/` | Starter code theo runtime |
