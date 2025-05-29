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