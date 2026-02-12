# Platform Deployment Pipeline

![Pipeline Status](https://img.shields.io/badge/status-active-success)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.28+-blue)
![Terraform](https://img.shields.io/badge/terraform-latest-purple)

## 📋 Overview

This GitHub Actions pipeline automates the deployment of a complete DevOps platform on AWS EKS, including:

- **AWS Load Balancer Controller** - Manages ALB/NLB for Kubernetes
- **NGINX Ingress Controller** - HTTP/HTTPS routing
- **ArgoCD** - GitOps continuous delivery
- **HashiCorp Vault** - Secrets management
- **Nexus Repository** - Artifact management
- **SonarQube** - Code quality analysis

## 🏗️ Architecture
```
┌─────────────────────────────────────────────┐
│           AWS EKS Cluster                    │
├─────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  ArgoCD  │  │  Vault   │  │  Nexus   │  │
│  └──────────┘  └──────────┘  └──────────┘  │
│  ┌──────────┐  ┌─────────────────────────┐ │
│  │SonarQube │  │   NGINX Ingress         │ │
│  └──────────┘  └─────────────────────────┘ │
│  ┌─────────────────────────────────────────┤
│  │   AWS Load Balancer Controller          │
│  └─────────────────────────────────────────┘
└─────────────────────────────────────────────┘
```

## 📁 Repository Structure
```
.
├── .github/
│   └── workflows/
│       ├── platformpipeline.yaml    # Main deployment pipeline
│       └── infrapipeline.yaml       # Infrastructure provisioning
├── k8s-configs/
│   ├── argocd-values.yaml          # ArgoCD Helm values
│   ├── nexus-values.yaml           # Nexus Helm values
│   ├── sonar-values.yaml           # SonarQube Helm values
│   └── vault-secret.yaml           # Vault configuration
├── helmchart/
│   └── templates/
│       └── ingress.yaml            # Unified platform ingress
└── terraform/                       # Infrastructure as Code
```

## 🚀 Prerequisites

### 1. AWS Requirements
- AWS Account with appropriate permissions
- EKS cluster provisioned (via Terraform)
- EFS CSI Driver installed
- StorageClass `efs-sc` configured

### 2. GitHub Secrets
Configure the following secrets in your GitHub repository:
```
AWS_ACCESS_KEY_ID          # AWS access key
AWS_SECRET_ACCESS_KEY      # AWS secret key
```

### 3. Terraform Outputs
The pipeline expects these outputs from the infrastructure pipeline:
- `eks_cluster_name`
- `vpc_id`
- `lbc_iam_role_arn`

## 📝 Configuration Files

### k8s-configs/argocd-values.yaml
```yaml
server:
  service:
    type: ClusterIP
  ingress:
    enabled: true
    hosts:
      - argocd.yourdomain.com
```

### k8s-configs/nexus-values.yaml
```yaml
persistence:
  enabled: true
  storageClass: efs-sc
  size: 50Gi
```

### k8s-configs/sonar-values.yaml
```yaml
persistence:
  enabled: true
  storageClass: efs-sc
  size: 20Gi
```

## 🔧 Pipeline Usage

### Manual Trigger

1. Go to **Actions** tab in your GitHub repository
2. Select **Platform Deploy Pipeline**
3. Click **Run workflow**
4. Choose environment:
   - `nonprod` - Development/Testing
   - `prod` - Production

### Pipeline Steps

1. **Setup Phase**
   - Checkout repository
   - Download Terraform outputs
   - Configure AWS credentials
   - Setup kubectl & Helm

2. **Validation Phase**
   - Verify EFS StorageClass
   - Check EFS CSI Driver status
   - Clean up stale webhooks

3. **Infrastructure Phase**
   - Deploy AWS Load Balancer Controller
   - Deploy NGINX Ingress (NodePort mode)

4. **Platform Services Phase**
   - Deploy ArgoCD
   - Deploy HashiCorp Vault
   - Create Vault policies
   - Deploy Nexus Repository
   - Deploy SonarQube

5. **Finalization Phase**
   - Apply unified ingress configuration
   - Display deployment summary with access credentials

## 🔑 Post-Deployment Access

After successful deployment, the pipeline outputs:

### LoadBalancer DNS
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### ArgoCD
- **URL**: `https://<loadbalancer-dns>/argocd`
- **Username**: `admin`
- **Password**: Retrieved from secret (shown in pipeline output)

### Vault
- **URL**: `https://<loadbalancer-dns>/vault`
- **Root Token**: `root` (dev mode - **change in production!**)

### Nexus
- **URL**: `https://<loadbalancer-dns>/nexus`
- **Default Credentials**: `admin/admin123`

### SonarQube
- **URL**: `https://<loadbalancer-dns>/sonar`
- **Username**: `admin`
- **Password**: Configured in pipeline (default: `MyStrongPassword123`)

## 🛡️ Security Considerations

### ⚠️ Important for Production

1. **Vault Configuration**
   - Replace dev mode with production setup
   - Use proper seal/unseal mechanism
   - Implement auto-unseal with AWS KMS

2. **Secrets Management**
   - Rotate all default passwords
   - Use AWS Secrets Manager or Parameter Store
   - Enable encryption at rest

3. **Network Security**
   - Configure security groups properly
   - Implement network policies
   - Use private subnets for workloads

4. **Access Control**
   - Enable RBAC in Kubernetes
   - Configure IAM roles for service accounts (IRSA)
   - Implement least privilege principle

## 🔍 Troubleshooting

### Pipeline Fails at "Verify Storage Readiness"
```bash
# Check if EFS CSI driver is installed
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-efs-csi-driver

# Verify StorageClass
kubectl get sc efs-sc
```

### Load Balancer Controller Issues
```bash
# Check controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify IAM role
kubectl describe sa aws-load-balancer-controller -n kube-system
```

### Vault Pod Not Ready
```bash
# Check vault pod status
kubectl get pods -n vault

# View vault logs
kubectl logs -n vault -l app.kubernetes.io/name=vault
```

### ArgoCD Password Not Found
```bash
# Manually retrieve ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

## 📊 Monitoring

### Check Deployment Status
```bash
# All namespaces
kubectl get pods --all-namespaces

# Specific service
kubectl get pods -n argocd
kubectl get pods -n vault
kubectl get pods -n nexus
kubectl get pods -n sonarqube
```

### View Logs
```bash
# ArgoCD
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server

# Vault
kubectl logs -n vault -l app.kubernetes.io/name=vault

# Nexus
kubectl logs -n nexus -l app=nexus

# SonarQube
kubectl logs -n sonarqube -l app.kubernetes.io/name=sonarqube
```

## 🔄 Updates and Maintenance

### Update Helm Charts
```bash
helm repo update
helm upgrade argocd argo/argo-cd -n argocd
```

### Backup Important Data
```bash
# Backup ArgoCD
kubectl get cm,secret -n argocd -o yaml > argocd-backup.yaml

# Backup Vault data (if using K8s backend)
kubectl exec -n vault vault-0 -- vault operator raft snapshot save backup.snap
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Contact the DevOps team
- Check the [troubleshooting guide](#-troubleshooting)

## 🎯 Roadmap

- [ ] Add External Secrets Operator integration
- [ ] Implement cert-manager for automatic SSL
- [ ] Add Prometheus & Grafana monitoring stack
- [ ] Integrate with Slack for notifications
- [ ] Add automated backup solutions
- [ ] Implement disaster recovery procedures

---

**Made with ❤️ by DevOps Team**

*Last Updated: February 2026*
