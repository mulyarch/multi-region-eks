
# Multi-Region EKS with Global Accelerator — CI/CD Pipeline - Lattice OS

A production-grade, multi-region Kubernetes deployment with automated CI/CD, Global Accelerator for anycast routing, and a modular Terraform architecture designed for easy region expansion. Built entirely with Infrastructure as Code — zero manual steps after initial setup.

##  Architecture

```
                         ┌──────────────────────────────┐
                         │     AWS Global Accelerator   │
                         │     (2 Static Anycast IPs)   │
                         └──────────────┬───────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
           ┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
           │   us-west-2     │ │   us-east-1     │ │   eu-west-1     │
           │   EKS + NLB     │ │   EKS + NLB     │ │   EKS + NLB     │
           │   2 Pods        │ │   2 Pods        │ │   2 Pods        │
           └─────────────────┘ └─────────────────┘ └─────────────────┘
```

**Users hit a single Global Accelerator endpoint → traffic routes to the nearest healthy region → NLB → EKS pods**

##  Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Infrastructure** | Terraform ~> 1.10 (modular) | VPC, EKS, ECR, IAM, Global Accelerator |
| **Container** | Docker (httpd:2.4-alpine) | Lightweight Apache web server |
| **Orchestration** | Amazon EKS (Kubernetes 1.32) | Container orchestration per region |
| **Registry** | Amazon ECR (per region) | Private Docker image storage |
| **Global Routing** | AWS Global Accelerator | Anycast IPs, health-based failover |
| **Load Balancing** | NLB (per region) | Layer 4 regional load balancing |
| **CI/CD** | GitHub Actions | Automated multi-region pipelines |
| **Security** | OIDC Federation, Trivy | Keyless auth, vulnerability scanning |
| **State** | S3 + Native Locking | Terraform state management |

##  Infrastructure Design

### Modular Architecture

The infrastructure uses a **reusable Terraform module** (`region-stack`) that encapsulates everything needed for one region:

```
terraform/
├── modules/
│   ├── region-stack/     ← Reusable: VPC + EKS + ECR + NLB
│   └── global/           ← Global Accelerator
├── main.tf               ← Instantiates region-stack per region
├── providers.tf          ← One provider per region
├── global-accelerator.tf ← Connects NLBs to Global Accelerator
└── environments/
    └── prod.tfvars
```

### Per-Region Stack

Each region gets:
- **VPC**: 3 AZs, public/private subnets, NAT Gateway
- **EKS Cluster**: Managed node groups (t3.medium), auto-scaling 1–3 nodes
- **ECR**: Private registry with lifecycle policies (retains last 10 images)
- **NLB**: Internet-facing Network Load Balancer for Global Accelerator endpoint

### Global Layer

- **Global Accelerator**: 2 static anycast IPs, health-based routing across all regions
- **Automatic Failover**: If a region goes unhealthy, traffic shifts in seconds

##  CI Pipeline

Triggered on: **Pull Requests** and **pushes to `develop`**

```
validate → build-and-test → push-to-ecr (all regions)
```

| Stage | Actions |
|-------|---------|
| **Validate** | Dockerfile lint (hadolint), Terraform validate/fmt |
| **Build & Test** | Docker build, HTTP smoke tests, Trivy CVE scan |
| **Push to ECR** | Build region-specific images, push to all regional ECRs |

##  CD Pipeline

Triggered on: **pushes to `main`**

```
terraform-deploy → build-push → deploy (3 regions parallel) → integration-tests → setup-global-accelerator
```

| Stage | Actions |
|-------|---------|
| **Terraform** | `terraform apply` — ensures all regional infra matches desired state |
| **Build & Push** | Region-tagged images pushed to each region's ECR |
| **Deploy** | Rolling update to all 3 EKS clusters (parallel, zero-downtime) |
| **Integration Tests** | Validates each region's NLB endpoint (HTTP 200, content) |
| **Global Accelerator** | Discovers NLB ARNs, configures endpoint groups |

### Pipeline Visualization

```
┌──────────────┐     ┌──────────────┐     ┌──────────────────────────────────┐
│  Terraform   │────▶│  Build &     │────▶│  Deploy (parallel)               │
│  Apply       │     │  Push to ECR │     │  ├── us-west-2                   │
└──────────────┘     └──────────────┘     │  ├── us-east-1                   │
                                          │  └── eu-west-1                   │
                                          └────────────────┬─────────────────┘
                                                           │
                                          ┌────────────────▼─────────────────┐
                                          │  Integration Tests (all regions) │
                                          └────────────────┬─────────────────┘
                                                           │
                                          ┌────────────────▼─────────────────┐
                                          │  Setup Global Accelerator        │
                                          └──────────────────────────────────┘
```

##  Security Highlights

- **No AWS Access Keys** — GitHub OIDC federation provides short-lived credentials
- **Scoped IAM Role** — Only this specific repo can assume the deployment role
- **Trivy Scanning** — Blocks images with CRITICAL/HIGH vulnerabilities
- **ECR Scan on Push** — AWS-native vulnerability detection
- **Private Subnets** — EKS worker nodes are not directly internet-accessible
- **EKS Access Entries** — Fine-grained cluster access control (no aws-auth ConfigMap)
- **Concurrency Control** — Pipeline runs are serialized to prevent state conflicts

##  Project Structure

```
├── app/
│   ├── index.html              # Application source (region-aware)
│   └── Dockerfile              # Multi-region container definition
├── terraform/
│   ├── backend.tf              # S3 state configuration
│   ├── providers.tf            # Multi-region provider definitions
│   ├── variables.tf            # Input variables
│   ├── main.tf                 # Region module instantiation
│   ├── github-oidc.tf          # OIDC + IAM role + policies
│   ├── global-accelerator.tf   # Global Accelerator configuration
│   ├── outputs.tf              # Output values (per region + global)
│   ├── modules/
│   │   ├── region-stack/       # Reusable: VPC + EKS + ECR
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── providers.tf
│   │   └── global/             # Global Accelerator module
│   └── environments/
│       └── prod.tfvars
├── k8s/
│   ├── namespace.yml           # Kubernetes namespace
│   ├── deployment.yml          # Deployment with rolling updates
│   └── service.yml             # NLB-backed LoadBalancer service
├── .github/workflows/
│   ├── ci.yml                  # CI pipeline (lint, build, test, push)
│   └── cd.yml                  # CD pipeline (deploy all regions)
└── .gitignore
```

##  Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.10
- Docker
- kubectl
- GitHub CLI (`gh`)

### Initial Setup

```bash
# Clone the repo
git clone https://github.com/mulyarch/multi-region-eks.git
cd multi-region-eks

# Deploy infrastructure
cd terraform
terraform init
terraform apply -var-file=environments/prod.tfvars

# Set GitHub secret
gh secret set AWS_ROLE_ARN --body "$(terraform output -raw github_actions_role_arn)"
```

### Development Workflow (100% Terminal)

```bash
# Create feature branch
git checkout develop && git pull origin develop
git checkout -b feature/my-change

# Make changes, commit, push
git add . && git commit -m "feat: my change"
git push origin feature/my-change

# Create PR → CI runs automatically
gh pr create --base develop --title "feat: my change" --body "Description"
gh run watch

# Merge to develop
gh pr merge --merge

# Deploy to production (all 3 regions)
git checkout develop && git pull origin develop
gh pr create --base main --head develop --title "Deploy" --body "Release"
gh pr merge --merge
gh run watch
```

## ➕ Adding a New Region

Adding a region requires only **4 changes** — no refactoring needed:

| # | File | Change |
|---|------|--------|
| 1 | `terraform/providers.tf` | Add aliased provider |
| 2 | `terraform/main.tf` | Add module block (unique CIDR) |
| 3 | `terraform/global-accelerator.tf` | Add endpoint group |
| 4 | `.github/workflows/cd.yml` | Add build/deploy/test steps |

Example — adding `ap-southeast-1`:

```hcl
# providers.tf
provider "aws" {
  alias  = "ap_southeast_1"
  region = "ap-southeast-1"
}

# main.tf
module "region_ap_southeast_1" {
  source = "./modules/region-stack"
  project_name            = var.project_name
  region                  = "ap-southeast-1"
  azs                     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  vpc_cidr                = "10.3.0.0/16"
  github_actions_role_arn = aws_iam_role.github_actions.arn
  providers = { aws = aws.ap_southeast_1 }
}
```

Push to `main` and the pipeline handles everything automatically.

##  Deployment Strategy

- **Rolling Updates**: New pods created before old ones terminate (maxSurge: 1, maxUnavailable: 0)
- **Health Checks**: Liveness and readiness probes on every pod
- **Parallel Deploys**: All 3 regions deploy simultaneously for speed
- **Automatic Failover**: Global Accelerator routes around unhealthy regions in <10 seconds
- **Concurrency Lock**: Only one CD pipeline runs at a time (prevents state conflicts)

##  Testing Strategy

| Level | Tool | What It Tests |
|-------|------|---------------|
| **Lint** | hadolint, terraform fmt | Code quality & standards |
| **Security** | Trivy | Known CVEs in container images |
| **Smoke** | curl | Container builds and responds correctly |
| **Integration** | curl + kubectl | Live NLB endpoint per region (HTTP 200) |
| **Global** | Global Accelerator health checks | Cross-region failover |

##  Key Design Decisions

| Decision | Rationale |
|----------|-----------|
| Modular Terraform | Add a region with one module call — DRY, scalable |
| OIDC over Access Keys | Security best practice — no credential rotation |
| S3 Native Locking | Simpler than DynamoDB, supported since Terraform 1.10 |
| NLB over ALB | Required for Global Accelerator, lower latency (Layer 4) |
| Per-region ECR | Images local to each region — faster pod startup |
| Global Accelerator over Route 53 | Static IPs, faster failover, no DNS TTL issues |
| EKS Access Entries over aws-auth | Modern, API-native, no ConfigMap drift |
| Concurrency control | Prevents Terraform state lock conflicts |
| Region-tagged images | Each region's container knows where it's running |

##  Global Accelerator Benefits

| Feature | Benefit |
|---------|---------|
| **2 Static Anycast IPs** | Single endpoint for all clients worldwide |
| **Health-based routing** | Automatic failover if a region goes down |
| **AWS backbone** | Traffic enters AWS network at nearest edge location |
| **No DNS propagation** | Failover in seconds, not minutes (unlike Route 53) |
| **DDoS protection** | Built-in AWS Shield Standard |

##  Future Enhancements

- [ ] Add Prometheus/Grafana monitoring per region
- [ ] Implement weighted routing for canary deployments
- [ ] Add Slack/PagerDuty notifications on deploy or failover
- [ ] Implement GitOps with ArgoCD for multi-cluster sync
- [ ] Add Helm charts for templated deployments
- [ ] Cross-region database replication (Aurora Global Database)
- [ ] Chaos engineering — automated region failure testing
- [ ] Cost optimization — spot instances for non-critical workloads

---

*Built as a hands-on project demonstrating production multi-region architecture, automated CI/CD, and infrastructure scalability on AWS.*
