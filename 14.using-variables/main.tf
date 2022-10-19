#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
#  Using Terraform Variables
#   Create:
#    - Security Group for Web Server and ELB
#    - Launch Configuration with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Classic Load Balancer in 2 Availability Zones
#  Update to Web Servers will be via Green/Blue Deployment Strategy
#
#  Made by Mustofa Kodirov
#----------------------------------------------------------

# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 3.74"
#     }
#   }
# }

provider "aws" {
  region = var.region
}
resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_eip" "eip_web" {
  instance = aws_instance.web.id
  tags     = merge(var.tags, { Name = "${var.tags["Environment"]}-EIP for Web Server Built by Terraform" })
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data              = file("user_data.sh")
  tags                   = merge(var.tags, { Name = "${var.tags["Environment"]}-Web Server Built by Terraform" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "web" {
  name   = "Web Security Group"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id
  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-Web Security Group" })
}