#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
# Using Elastic IP
#
# Made by Mustofa Kodirov
#----------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  tags = {
    Name : "EIP for WebServer  Built By Terraform"
    Owner : "Mustofa"
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-026b57f3c383c2eec" // Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  key_name               = "demo"
  user_data = templatefile("user-data.sh.tpl", {
    f_name           = "Mustofa",
    l_name           = "Kodirov",
    wanted_countries = ["UAE", "USA", "Canada", "Egypt"]
  })
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "my-sg" {
  name        = "WebServer-SG"
  description = "Security Group for my WebServer"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      description = "Allow port HTTP and HTTPS SSH also"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "WebServer SG by Terraform"
    Owner = "Mustofa Kodirov"
  }
}