# البحث عن الـ VPC عن طريق اسمها
data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# البحث عن الـ Public Subnets (عشان الـ Load Balancer مثلاً)
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*public*"] # بيفترض إنك مسمية الـ subnets وفيهم كلمة public
  }
}

# البحث عن الـ Private Subnets (عشان الـ EKS Nodes والـ Database)
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"] # بيفترض إنك مسمية الـ subnets وفيهم كلمة private
  }
}

