# ==========================================
# Security Group for EKS Worker Nodes
# ==========================================
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "SG for EKS Worker Nodes"
  vpc_id      = aws_vpc.main.id

  # 1. السماح بالوصول للـ Kubernetes API من أي مكان
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2. التعديل الجديد: السماح للـ Load Balancer بالوصول للـ Nodes داخلياً
  # هذا السطر يربط الـ Security Groups ببعضها البعض
  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
    description     = "Allow internal traffic from API Gateway to EKS Nodes"
  }

  # السماح بكل حركة الصادرة
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-nodes-sg"
    Environment = var.environment
  }
}

# ==========================================
# Security Group for Load Balancer
# ==========================================
resource "aws_security_group" "lb_sg" {
  name        = "${var.cluster_name}-lb-sg"
  description = "SG for Network Load Balancer"
  vpc_id      = aws_vpc.main.id

  # السماح بالوصول على HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # السماح بالوصول على HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # السماح بكل حركة الصادرة
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-lb-sg"
    Environment = var.environment
  }
}

