# Helm Chart - Platform Services

![Helm](https://img.shields.io/badge/helm-v3-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-1.28+-326CE5)
![License](https://img.shields.io/badge/license-MIT-green)

## 📋 Overview

This Helm chart provides a unified ingress configuration for all platform services deployed on the EKS cluster. It consolidates access to ArgoCD, Vault, Nexus, and SonarQube through a single Application Load Balancer (ALB) with path-based routing.

## 🏗️ Architecture
```
                    Internet
                        ↓
              AWS Load Balancer (ALB)
                        ↓
            ┌───────────────────────┐
            │   NGINX Ingress       │
            │    (NodePort)         │
            └───────────────────────┘
                        ↓
        ┌───────────────┴───────────────┐
        │                               │
    /argocd                         /vault
        │                               │
    ┌───────┐                      ┌───────┐
    │ArgoCD │                      │ Vault │
    │Service│                      │Service│
    └───────┘                      └───────┘
        │                               │
    /nexus                          /sonar
        │                               │
    ┌───────┐                      ┌───────┐
    │ ECR │                      │Semgrep│
    │Service│                      │Service│
    └───────┘                      └───────┘
```

## 📁 Directory Structure
```
helmchart/
├── Chart.yaml                 # Helm chart metadata
├── values.yaml               # Default configuration values
└── templates/
    ├── ingress.yaml          # Unified ALB ingress configuration
    ├── _helpers.tpl          # Template helpers (optional)
    └── NOTES.txt             # Post-install instructions (optional)
```

## 📝 Files Description

### 1. Chart.yaml

Defines the Helm chart metadata:
```yaml
apiVersion: v2
name: platform-services
description: Unified ingress for platform services
type: application
version: 1.0.0
appVersion: "1.0"
keywords:
  - argocd
  - vault
  - nexus
  - sonarqube
  - ingress
maintainers:
  - name: DevOps Team
    email: devops@company.com
```

**Key Fields:**
- `apiVersion`: Helm chart API version (v2 for Helm 3)
- `name`: Chart name used for installation
- `version`: Chart version (semantic versioning)
- `appVersion`: Version of the application being deployed

### 2. values.yaml

Contains default configuration values:
```yaml
# Default values for platform-services

ingress:
  enabled: true
  className: "alb"
  
  annotations:
    # AWS Load Balancer Controller annotations
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: instance
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '30'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
    
    # Certificate (optional - uncomment when ready)
    # alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/xxxxx
    
  hosts:
    - host: ""  # Empty for ALB DNS
      paths:
        - path: /argocd
          pathType: Prefix
          service:
            name: argocd-server
            namespace: argocd
            port: 80
            
        - path: /vault
          pathType: Prefix
          service:
            name: vault
            namespace: vault
            port: 8200
            
        - path: /nexus
          pathType: Prefix
          service:
            name: nexus-repository-manager
            namespace: nexus
            port: 8081
            
        - path: /sonar
          pathType: Prefix
          service:
            name: sonarqube
            namespace: sonarqube
            port: 9000

# Service-specific configurations
argocd:
  namespace: argocd
  serviceName: argocd-server
  servicePort: 80

vault:
  namespace: vault
  serviceName: vault
  servicePort: 8200

nexus:
  namespace: nexus
  serviceName: nexus-repository-manager
  servicePort: 8081

sonarqube:
  namespace: sonarqube
  serviceName: sonarqube
  servicePort: 9000
```

### 3. templates/ingress.yaml

The main ingress resource template:
```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Chart.Name }}-ingress
  namespace: {{ .Values.ingress.namespace | default "default" }}
  annotations:
    {{- toYaml .Values.ingress.annotations | nindent 4 }}
  labels:
    app.kubernetes.io/name: {{ .Chart.Name }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  ingressClassName: {{ .Values.ingress.className }}
  rules:
  {{- range .Values.ingress.hosts }}
  - http:
      paths:
      {{- range .paths }}
      - path: {{ .path }}
        pathType: {{ .pathType }}
        backend:
          service:
            name: {{ .service.name }}
            port:
              number: {{ .service.port }}
      {{- end }}
  {{- end }}
{{- end }}
```

**Template Features:**
- **Conditional Rendering**: Only creates ingress if `enabled: true`
- **Dynamic Values**: Uses `.Values` for all configurations
- **Labels**: Adds standard Kubernetes labels for management
- **Flexible Routing**: Supports multiple paths and services

## 🚀 Installation Methods

### Method 1: Via Pipeline (Automated)

The ingress is automatically deployed by the platform pipeline:
```yaml
- name: Apply Unified Platform Ingress
  run: |
    kubectl apply -f helmchart/templates/ingress.yaml
```

### Method 2: Using Helm CLI (Manual)
```bash
# Install the chart
helm install platform-services ./helmchart

# Install with custom values
helm install platform-services ./helmchart \
  -f custom-values.yaml

# Install in specific namespace
helm install platform-services ./helmchart \
  -n platform-ingress --create-namespace
```

### Method 3: Using kubectl (Direct Apply)
```bash
# Apply just the ingress
kubectl apply -f helmchart/templates/ingress.yaml

# Apply with kustomize
kubectl apply -k helmchart/
```

## ⚙️ Configuration Options

### Basic Configuration
```yaml
# Enable/disable ingress
ingress:
  enabled: true
```

### ALB Configuration
```yaml
ingress:
  annotations:
    # Public or internal ALB
    alb.ingress.kubernetes.io/scheme: internet-facing  # or 'internal'
    
    # Target type
    alb.ingress.kubernetes.io/target-type: instance    # or 'ip'
    
    # SSL/TLS
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...
    alb.ingress.kubernetes.io/ssl-redirect: '443'
```

### Health Check Configuration
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/healthcheck-path: /healthz
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '30'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
```

### Adding New Services

To add a new service to the ingress:
```yaml
hosts:
  - host: ""
    paths:
      # ... existing paths ...
      
      # Add new service
      - path: /grafana
        pathType: Prefix
        service:
          name: grafana
          namespace: monitoring
          port: 3000
```

## 🔧 Customization Examples

### Example 1: Custom Domain with SSL
```yaml
# custom-values.yaml
ingress:
  enabled: true
  className: "alb"
  
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:123456789012:certificate/abcd1234
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
    
  hosts:
    - host: "platform.example.com"
      paths:
        - path: /argocd
          pathType: Prefix
          service:
            name: argocd-server
            namespace: argocd
            port: 80
```

Apply with:
```bash
helm upgrade --install platform-services ./helmchart \
  -f custom-values.yaml
```

### Example 2: Internal Load Balancer
```yaml
# internal-values.yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/subnets: subnet-12345,subnet-67890
    alb.ingress.kubernetes.io/security-groups: sg-abcdef
```

### Example 3: IP Target Type (for Fargate)
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/backend-protocol: HTTP
```

## 📊 Monitoring & Verification

### Check Ingress Status
```bash
# Get ingress details
kubectl get ingress -A

# Describe ingress
kubectl describe ingress platform-services-ingress

# Get ALB DNS name
kubectl get ingress platform-services-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

### Check ALB in AWS Console

1. Navigate to **EC2 → Load Balancers**
2. Find ALB with tag: `ingress.k8s.aws/stack=platform-services-ingress`
3. Check:
   - Target Groups health
   - Listener rules
   - Security groups
   - Access logs

### Test Service Accessibility
```bash
# Get ALB DNS
ALB_DNS=$(kubectl get ingress platform-services-ingress \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test each service
curl http://$ALB_DNS/argocd
curl http://$ALB_DNS/vault/ui
curl http://$ALB_DNS/nexus
curl http://$ALB_DNS/sonar
```

## 🛠️ Troubleshooting

### Issue 1: Ingress Not Creating ALB

**Symptoms:**
```bash
kubectl get ingress
# Shows no EXTERNAL-IP
```

**Solutions:**
```bash
# 1. Check AWS Load Balancer Controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# 2. Check controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# 3. Verify IAM role
kubectl describe sa aws-load-balancer-controller -n kube-system

# 4. Check ingress events
kubectl describe ingress platform-services-ingress
```

### Issue 2: 404 Not Found

**Symptoms:**
```bash
curl http://$ALB_DNS/argocd
# Returns 404
```

**Solutions:**
```bash
# 1. Check service exists
kubectl get svc -n argocd argocd-server

# 2. Check service endpoints
kubectl get endpoints -n argocd argocd-server

# 3. Verify ingress rules
kubectl get ingress platform-services-ingress -o yaml

# 4. Check target group in AWS console
# Ensure targets are healthy
```

### Issue 3: Service Behind Ingress Not Working

**Symptoms:**
```bash
# Direct service access works
kubectl port-forward -n argocd svc/argocd-server 8080:80
curl http://localhost:8080  # Works

# Ingress access fails
curl http://$ALB_DNS/argocd  # Fails
```

**Solutions:**

Check service configuration:
```yaml
# Some services need base path configuration
# ArgoCD example:
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: http://$ALB_DNS/argocd
```

### Issue 4: SSL/TLS Certificate Issues

**Symptoms:**
```
Certificate validation failed
```

**Solutions:**
```bash
# 1. Verify certificate ARN
aws acm list-certificates --region us-east-1

# 2. Check certificate status
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/xxxxx

# 3. Verify domain validation
# Certificate must be ISSUED status

# 4. Update ingress annotation
kubectl annotate ingress platform-services-ingress \
  alb.ingress.kubernetes.io/certificate-arn=arn:aws:acm:... \
  --overwrite
```

## 🔐 Security Best Practices

### 1. Enable SSL/TLS
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS": 443}]'
```

### 2. Restrict Access by IP
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/security-groups: sg-restrictive
    # Or use inbound rules in security group to whitelist IPs
```

### 3. Use Internal Load Balancer for Sensitive Services
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/scheme: internal
    alb.ingress.kubernetes.io/subnets: subnet-private-1,subnet-private-2
```

### 4. Enable WAF
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/wafv2-acl-arn: arn:aws:wafv2:...
```

### 5. Enable Access Logs
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/load-balancer-attributes: >
      access_logs.s3.enabled=true,
      access_logs.s3.bucket=my-alb-logs,
      access_logs.s3.prefix=platform-ingress
```

## 📈 Advanced Configuration

### Multiple Host Support
```yaml
hosts:
  - host: "argocd.example.com"
    paths:
      - path: /
        pathType: Prefix
        service:
          name: argocd-server
          namespace: argocd
          port: 80
          
  - host: "vault.example.com"
    paths:
      - path: /
        pathType: Prefix
        service:
          name: vault
          namespace: vault
          port: 8200
```

### Custom Headers
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/actions.ssl-redirect: |
      {
        "Type": "redirect",
        "RedirectConfig": {
          "Protocol": "HTTPS",
          "Port": "443",
          "StatusCode": "HTTP_301"
        }
      }
```

### Sticky Sessions
```yaml
ingress:
  annotations:
    alb.ingress.kubernetes.io/target-group-attributes: >
      stickiness.enabled=true,
      stickiness.lb_cookie.duration_seconds=86400
```

## 🔄 Upgrade & Maintenance

### Upgrade Chart
```bash
# Upgrade with new values
helm upgrade platform-services ./helmchart \
  -f values.yaml

# Force upgrade
helm upgrade platform-services ./helmchart \
  --force

# Rollback if needed
helm rollback platform-services 1
```

### Update Ingress Configuration
```bash
# Edit values
vim helmchart/values.yaml

# Apply changes
kubectl apply -f helmchart/templates/ingress.yaml

# Or use helm
helm upgrade platform-services ./helmchart
```

### Add New Service Dynamically
```bash
# Create patch file
cat > add-grafana.yaml <<EOF
ingress:
  hosts:
    - host: ""
      paths:
        - path: /grafana
          pathType: Prefix
          service:
            name: grafana
            namespace: monitoring
            port: 3000
EOF

# Apply patch
helm upgrade platform-services ./helmchart \
  -f values.yaml \
  -f add-grafana.yaml
```

## 📚 Related Documentation

- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Kubernetes Ingress Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Helm Chart Best Practices](https://helm.sh/docs/chart_best_practices/)
- [ArgoCD with Ingress](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/)

## 🤝 Contributing

To contribute to this Helm chart:

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-service`
3. Update `values.yaml` and `templates/ingress.yaml`
4. Test locally: `helm template ./helmchart`
5. Commit changes: `git commit -m "Add new service"`
6. Create Pull Request

## 📋 Checklist

Before deploying:

- [ ] AWS Load Balancer Controller installed
- [ ] All services deployed and running
- [ ] Service names and ports verified
- [ ] Namespaces created
- [ ] SSL certificate created (if using HTTPS)
- [ ] DNS records configured (if using custom domain)
- [ ] Security groups configured
- [ ] Health check paths verified

## 🎯 Future Enhancements

- [ ] Add cert-manager integration for automatic SSL
- [ ] Add OAuth2 proxy for authentication
- [ ] Add rate limiting configurations
- [ ] Add multiple environment support (dev/staging/prod)
- [ ] Add Prometheus metrics annotations
- [ ] Add external-dns integration

---

**Chart Version**: 1.0.0  
**Last Updated**: February 2026  
**Maintained by**: DevOps Team

---

## 📞 Support

For issues or questions:
- Create an issue in the repository
- Contact DevOps team on Slack: #devops-support
- Check AWS Load Balancer Controller logs

## 📄 License

This Helm chart is licensed under the MIT License.
