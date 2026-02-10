
# 1. إنشاء نظام ملفات EFS
resource "aws_efs_file_system" "eks" {
  creation_token = "eks-efs"
  tags = { Name = "${var.cluster_name}-efs" }
}

# 2. إنشاء نقاط الاتصال (Mount Targets) في الـ Private Subnets

resource "aws_efs_mount_target" "eks" {
  # بدلاً من استخدام كل السابنتس، سنستخدم أول سابنت في كل AZ فريدة
  count           = length(var.azs) 
  file_system_id  = aws_efs_file_system.eks.id
  # نختار سابنت واحدة فقط لكل منطقة توافر
  subnet_id       = aws_subnet.private[count.index].id 
  security_groups = [aws_security_group.efs_sg.id]
}



# 3. تعريف الـ StorageClass في Kubernetes
resource "kubernetes_storage_class_v1" "efs" {
  metadata { name = "efs-sc" }
  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.eks.id
    directoryPerms   = "700"
  }
}