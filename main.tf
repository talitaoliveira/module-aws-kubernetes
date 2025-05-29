provider "aws" {
    region = var.aws_region
}

locals {
  cluster_name = "${var.cluster_name}-${var.env_name}"
}

# Trust Policy to allow EKS service assume role and execute actions
resource "aws_iam_role" "ms-cluster" {
    name = local.cluster_name

    assume_role_policy = <<POLICY
    {
     "Version": "2012-10-17",
     "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
     ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "ms-cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.ms-cluster.name
} 


# Create network security group

resource "aws_security_group" "ms-cluster" {
    name = local.cluster
    vpc_id = var.vpc_id # Using the VPC previously created

    egress { # Allows unrestricted outbound traffic
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # But no inbound traffic because there's no ingress rule

    tags {
        Name = "ms-up-running"
    }
}

# Cluster definition

resource "aws_eks_cluster" "ms-up-running" {
    name = local.cluster_name
    role_arn = aws_iam_role.ms-cluster.arn

    vpc_config {
        security_group_ids = [aws_security_group.ms-cluster.id]
        subnet_ids = var.cluster_subnet_ids
    }

    depends_on = [
        aws_iam_role_policy_attachment.ms-cluster-AmazonEKSClusterPolicy
    ]
}

# Node Role
resource "aws_iam_role" "ms-node" {
    name = "${local.cluster_name}.node"

    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
     "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
     ]
    }
    POLICY
}

# Node Policy
resource "aws_iam_role_policy_attachment" "ms-node-AmazonEKSWorkerNodePolicy" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.ms-node.name
}

resource "aws_iam_role_policy_attachment" "ms-node-AmazonEKS_CNI_Policy" {
    policy_arn = "arn:aws:iam:aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.ms-node.name
}

resource "aws_iam_role_policy_attachment" "ms-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.ms-node.name
}