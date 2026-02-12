# Terraform Infrastructure Pipeline

![Terraform](https://img.shields.io/badge/terraform-1.5.7-purple)
![AWS](https://img.shields.io/badge/AWS-EKS-orange)
![Pipeline](https://img.shields.io/badge/pipeline-automated-green)

## 📋 Overview

This GitHub Actions pipeline automates the provisioning and destruction of AWS infrastructure using Terraform. It supports multiple environments and provides safe infrastructure management with plan/apply workflows.

## 🏗️ Infrastructure Components

The Terraform configuration provisions:

- **AWS VPC** - Virtual Private Cloud with public/private subnets
- **EKS Cluster** - Managed Kubernetes cluster
- **EFS** - Elastic File System for persistent storage
- **EFS CSI Driver** - Kubernetes storage driver
- **IAM Roles** - Service accounts and permissions
- **Security Groups** - Network access control
- **Load Balancer Controller Role** - For AWS ALB/NLB integration

## 📁 Repository Structure
```
.
├── .github/
│   └── workflows/
│       ├── infrapipeline.yaml       # This Terraform pipeline
│       └── platformpipeline.yaml    # Platform deployment pipeline
├── terraform/
│   ├── main.tf                      # Main Terraform configuration
│   ├── variables.tf                 # Variable definitions
│   ├── outputs.tf                   # Output definitions
│   ├── nonprod.tfvars              # Non-production variables
│   ├── prod.tfvars                 # Production variables
│   ├── providers.tf                # AWS provider configuration
│   └── backend.tf                  # S3 backend configuration (optional)
└── README.md
```

## 🚀 Prerequisites

### 1. AWS Account Setup
- AWS Account with appropriate permissions
- IAM user with programmatic access
- Permissions required:
```
  - EC2 (VPC, Subnets, Security Groups)
  - EKS (Cluster management)
  - EFS (File system creation)
  - IAM (Roles and policies)
  - S3 (for Terraform state - optional)
```

### 2. GitHub Secrets Configuration

Navigate to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

### 3. Terraform State Backend (Recommended for Production)

Create `terraform/backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "eks-platform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## 📝 Environment Files

### nonprod.tfvars
```hcl
environment         = "nonprod"
cluster_name        = "eks-nonprod"
cluster_version     = "1.28"
vpc_cidr            = "10.0.0.0/16"
instance_types      = ["t3.medium"]
desired_size        = 2
min_size            = 1
max_size            = 4
```

### prod.tfvars
```hcl
environment         = "prod"
cluster_name        = "eks-prod"
cluster_version     = "1.28"
vpc_cidr            = "10.1.0.0/16"
instance_types      = ["t3.large"]
desired_size        = 3
min_size            = 3
max_size            = 10
```

## 🎯 Pipeline Usage

### Creating Infrastructure

1. Go to **Actions** tab in GitHub
2. Select **Terraform Pipeline**
3. Click **Run workflow**
4. Configure options:
   - **Environment**: Choose `nonprod` or `prod`
   - **Destroy Infrastructure**: Keep as `false`
5. Click **Run workflow**

### Destroying Infrastructure

⚠️ **WARNING**: This will destroy all resources!

1. Go to **Actions** tab
2. Select **Terraform Pipeline**
3. Click **Run workflow**
4. Configure options:
   - **Environment**: Choose target environment
   - **Destroy Infrastructure**: Set to `true`
5. Click **Run workflow**

## 🔄 Pipeline Stages

### Stage 1: Initialization
```yaml
✓ Checkout repository
✓ Setup Terraform 1.5.7
✓ Configure AWS credentials
```

### Stage 2: Planning
```yaml
✓ Terraform Init - Initialize backend and providers
✓ Terraform Plan - Generate execution plan
  - For Apply: Shows resources to create/modify
  - For Destroy: Shows resources to delete
```

### Stage 3: Execution
```yaml
✓ Terraform Apply - Execute the plan
✓ Generate Outputs - Export cluster details
✓ Upload Artifact - Share outputs with platform pipeline
```

## 📤 Pipeline Outputs

After successful execution, the pipeline generates `tf-outputs.json`:
```json
{
  "eks_cluster_name": {
    "value": "eks-nonprod"
  },
  "vpc_id": {
    "value": "vpc-0123456789abcdef"
  },
  "lbc_iam_role_arn": {
    "value": "arn:aws:iam::123456789012:role/eks-lbc-role"
  },
  "efs_id": {
    "value": "fs-0123456789abcdef"
  }
}
```

These outputs are used by the **Platform Deploy Pipeline** to configure Kubernetes resources.

## 🔗 Integration with Platform Pipeline

The Terraform pipeline creates infrastructure artifacts that are consumed by the platform deployment:
```mermaid
graph LR
    A[Terraform Pipeline] -->|Creates| B[EKS Cluster]
    A -->|Generates| C[tf-outputs.json]
    C -->|Downloaded by| D[Platform Pipeline]
    D -->|Deploys to| B
    D -->|Installs| E[ArgoCD, Vault, Nexus, etc.]
```

## 🛡️ Security Features

### 1. **Input Validation**
```yaml
env:
  TF_ENV: ${{ github.event.inputs.env }}      # Prevents injection
  TF_DESTROY: ${{ github.event.inputs.destroy }}
```

### 2. **Safe Execution**
```bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures
```

### 3. **Secrets Management**
- AWS credentials stored in GitHub Secrets
- Never logged or exposed in pipeline output
- Automatic credential rotation recommended

### 4. **Plan Before Apply**
- Always generates plan before execution
- Review changes in GitHub Actions logs
- Explicit approval through manual workflow trigger

## 📊 Monitoring & Troubleshooting

### Check Pipeline Status
```bash
# View recent workflow runs
gh run list --workflow=infrapipeline.yaml

# View specific run details
gh run view <run-id>

# Download artifacts
gh run download <run-id>
```

### Common Issues

#### 1. **Terraform Init Fails**
```
Error: Failed to get existing workspaces
```
**Solution**: Check S3 backend configuration and permissions

#### 2. **Insufficient Permissions**
```
Error: UnauthorizedOperation
```
**Solution**: Verify IAM user has required permissions

#### 3. **State Lock Error**
```
Error: Error acquiring the state lock
```
**Solution**: 
```bash
# Force unlock (use with caution)
cd terraform
terraform force-unlock <lock-id>
```

#### 4. **Resource Quota Exceeded**
```
Error: VPC limit exceeded
```
**Solution**: Request quota increase in AWS Service Quotas

### Terraform State Management

#### View Current State
```bash
cd terraform
terraform state list
```

#### Check Specific Resource
```bash
terraform state show aws_eks_cluster.main
```

#### Remove Resource from State
```bash
terraform state rm aws_efs_file_system.eks_efs
```

## 🔧 Customization

### Adding New Variables

1. **Define in `variables.tf`**:
```hcl
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}
```

2. **Add to `nonprod.tfvars`**:
```hcl
enable_monitoring = true
```

3. **Use in `main.tf`**:
```hcl
resource "aws_eks_cluster" "main" {
  name = var.cluster_name
  
  enabled_cluster_log_types = var.enable_monitoring ? [
    "api", "audit", "authenticator"
  ] : []
}
```

### Adding New Outputs

In `outputs.tf`:
```hcl
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = false
}

output "cluster_certificate" {
  description = "EKS cluster certificate"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}
```

## 📈 Cost Management

### Estimated Monthly Costs (us-east-1)

| Component | nonprod | prod |
|-----------|---------|------|
| EKS Control Plane | $73 | $73 |
| EC2 Instances (t3.medium x2) | $60 | - |
| EC2 Instances (t3.large x3) | - | $190 |
| EFS Storage (50GB) | $15 | $15 |
| NAT Gateway | $32 | $96 |
| Load Balancer | $16 | $48 |
| **Total** | **~$196/month** | **~$422/month** |

### Cost Optimization Tips

1. **Use Spot Instances** for non-prod:
```hcl
capacity_type = "SPOT"
```

2. **Auto-scaling**:
```hcl
min_size = 1
max_size = 10
desired_size = 2
```

3. **Scheduled Shutdown** for dev environments:
```bash
# Stop cluster after hours
aws eks update-nodegroup-config --cluster-name eks-nonprod \
  --nodegroup-name main --scaling-config desiredSize=0
```

## 🚨 Disaster Recovery

### Backup State File
```bash
# Manual backup
cd terraform
terraform state pull > backup-$(date +%Y%m%d).tfstate

# Store in S3
aws s3 cp backup-*.tfstate s3://my-backup-bucket/terraform/
```

### Restore from Backup
```bash
# Push backup to current state
terraform state push backup-20240212.tfstate
```

### Emergency Procedures

#### Complete Infrastructure Loss
1. Restore Terraform state from backup
2. Run `terraform plan` to verify drift
3. Run `terraform apply` to recreate resources
4. Restore application data from backups

## 📚 Best Practices

### 1. **Always Use Workspaces for Multi-Environment**
```bash
terraform workspace new prod
terraform workspace select prod
```

### 2. **Pin Provider Versions**
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 3. **Tag All Resources**
```hcl
tags = {
  Environment = var.environment
  ManagedBy   = "Terraform"
  Project     = "EKS-Platform"
  Owner       = "DevOps-Team"
}
```

### 4. **Use Remote State**
- Never commit `terraform.tfstate` to Git
- Always use S3 backend with encryption
- Enable state locking with DynamoDB

### 5. **Review Plans Before Apply**
- Check pipeline logs before manual approval
- Verify resource counts and changes
- Look for unexpected deletions

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/new-resource`
2. Make changes to Terraform files
3. Test locally: `terraform plan`
4. Commit: `git commit -m "Add new resource"`
5. Push: `git push origin feature/new-resource`
6. Create Pull Request

## 📞 Support

### Getting Help
- **Issues**: Create an issue in this repository
- **DevOps Team**: Contact via Slack #devops-support
- **AWS Support**: For AWS-specific issues

### Useful Commands
```bash
# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Show current state
terraform show

# List all resources
terraform state list

# Import existing resource
terraform import aws_vpc.main vpc-12345678
```

## 📋 Checklist Before Running

- [ ] AWS credentials configured in GitHub Secrets
- [ ] Terraform variables file (`.tfvars`) reviewed
- [ ] S3 backend bucket created (if using remote state)
- [ ] Cost estimates reviewed
- [ ] Backup plan in place
- [ ] Team notified of infrastructure changes
- [ ] Maintenance window scheduled (for prod)

## 🎯 Roadmap

- [ ] Add Terraform Cloud integration
- [ ] Implement drift detection
- [ ] Add automated testing with Terratest
- [ ] Create separate VPCs per environment
- [ ] Add disaster recovery automation
- [ ] Implement cost anomaly detection

---

**Last Updated**: February 2026  
**Maintained by**: DevOps Team  
**Terraform Version**: 1.5.7  
**AWS Region**: us-east-1

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
