provider "aws" {
    region = var.aws_region
}

locals {
  cluster_name = "${var.cluster_name}-${var.env_name}"
}

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