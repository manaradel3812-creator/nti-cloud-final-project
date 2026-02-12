# CD Pipeline - ArgoCD Integration

## 🎯 Overview

This CD pipeline automatically deploys your application to EKS using ArgoCD GitOps methodology. It pulls the Docker image from ECR and updates the ArgoCD application.

## 🔄 Workflow
```
CI Pipeline (Build) → ECR (Store Image) → CD Pipeline (Deploy) → ArgoCD (GitOps) → EKS (Running App)
```

## 🚀 How It Works

### Automatic Trigger
1. CI pipeline completes successfully
2. CD pipeline automatically starts
3. Downloads CI outputs (cluster name, ECR repo, image tag)
4. Updates ArgoCD application
5. Syncs application to deploy new version

### Manual Trigger
1. Go to Actions → CD Pipeline
2. Click "Run workflow"
3. Enter image tag to deploy
4. Select environment (nonprod/prod)

## 📋 Prerequisites

- ArgoCD installed on EKS cluster
- ECR repository created
- GitHub repository with Helm charts
- AWS credentials configured

## 🔧 Setup Steps

### 1. Create ArgoCD Application
```bash
kubectl apply -f argocd/application.yaml
```

### 2. (Optional) Install ArgoCD Image Updater
```bash
# Run the setup workflow
gh workflow run setup-argocd-image-updater.yaml
```

### 3. Configure GitHub Secrets

Add to repository secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `ECR_REPOSITORY_URL` (optional for manual runs)
- `SLACK_WEBHOOK` (optional for notifications)

## 📊 Monitoring

### Check ArgoCD Application
```bash
# Get application status
kubectl get application -n argocd

# Describe application
kubectl describe application manar-app -n argocd
```

### Check Deployed Pods
```bash
# Get pods
kubectl get pods -n default -l app=manar-app

# Get deployment status
kubectl rollout status deployment/manar-app -n default
```

### ArgoCD UI

Access at: `https://<alb-dns>/argocd`

## 🔍 Troubleshooting

### Application Not Syncing
```bash
# Force sync
argocd app sync manar-app --force

# Check sync status
argocd app get manar-app
```

### Image Pull Errors
```bash
# Check ECR authentication
kubectl get pods -n default -l app=manar-app -o yaml | grep -A 10 "ImagePullBackOff"

# Verify ECR credentials
aws ecr get-login-password --region us-east-1
```

## 🎨 Customization

### Change Sync Policy

Edit `argocd/application.yaml`:
```yaml
syncPolicy:
  automated:
    prune: true      # Delete old resources
    selfHeal: true   # Auto-sync on drift
```

### Add Environment-Specific Values

Create `helmchart/values-prod.yaml`:
```yaml
replicaCount: 5
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
```

Update application:
```yaml
source:
  helm:
    valueFiles:
      - values-prod.yaml
```

## ✅ Success Criteria

- ✅ CI pipeline completes
- ✅ CD pipeline triggers automatically
- ✅ ArgoCD application syncs
- ✅ Pods are running and healthy
- ✅ New image tag deployed

---

**Last Updated**: February 2026
