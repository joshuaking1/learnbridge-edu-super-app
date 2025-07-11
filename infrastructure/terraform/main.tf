# Fetches available availability zones in the selected region for high availability.
data "aws_availability_zones" "available" {}

# Creates a Virtual Private Cloud (VPC) to house our infrastructure in an isolated network.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.project_name}-VPC"
  }
}

# Creates public subnets for resources that need to be accessible from the internet (e.g., load balancers).
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-PublicSubnet-${count.index + 1}"
  }
}

# Creates an IAM role that Kubernetes (EKS) will assume to manage AWS resources.
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-EKSClusterRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the necessary AWS-managed policy for the EKS cluster role.
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Defines and provisions the Elastic Kubernetes Service (EKS) cluster.
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-Cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.public.*.id
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name = "${var.project_name}-EKS-Cluster"
  }
}

output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "aws_region" {
  value = var.aws_region
}