
variable "cluster_name" {
  description = "Name of cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of cluster"
  type        = string
  default = "1.26"
}

variable "key_name" {
  description = "SSH keypair name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "node_id" {
  description = "Identifier for data node"
  type        = string
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "k8s-node" {
  name               = "k8s-node-${var.node_id}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "k8s-node" {
  role       = aws_iam_role.k8s-node.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "k8s-node" {
  name = "k8s-node-${var.node_id}"
  role = aws_iam_role.k8s-node.name
}

resource "aws_instance" "self" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true
  instance_type               = "t3.medium"
  iam_instance_profile        = aws_iam_instance_profile.k8s-node.id
  key_name                    = var.key_name
  user_data = templatefile("${path.module}/user_data.tmpl", {
    bucket_name = var.bucket_name
    cluster_version = var.cluster_version
  })
  tags = {
    Name = "k8s-${var.cluster_name}-node"
  }
}

output "public-dns" {
  value = aws_instance.self.public_dns
}
