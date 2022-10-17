#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
# Using Dependency featute from Terraform
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

resource "aws_instance" "web_server" {
  ami                    = "ami-026b57f3c383c2eec" // Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  key_name               = "demo"
  tags                   = { Name : "Web server" }
  user_data = templatefile("user-data.sh.tpl", {
    f_name           = "Mustofa",
    l_name           = "Kodirov",
    wanted_countries = ["UAE", "USA", "Canada", "Egypt"]
  })
  depends_on = [
    aws_instance.db_server,
    aws_instance.app_server
  ]
}

resource "aws_instance" "app_server" {
  ami                    = "ami-026b57f3c383c2eec" // Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  key_name               = "demo"
  tags                   = { Name : "App server" }
  user_data = templatefile("user-data.sh.tpl", {
    f_name           = "Mustofa",
    l_name           = "Kodirov",
    wanted_countries = ["UAE", "USA", "Canada", "Egypt"]
  })
  depends_on = [aws_instance.db_server]
}

resource "aws_instance" "db_server" {
  ami                    = "ami-026b57f3c383c2eec" // Amazon Linux2
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.general.id]
  key_name               = "demo"
  tags                   = { Name : "My DB server" }
}

# resource "aws_security_group" "general" { 

# }
resource "aws_security_group" "general" {
  name = "Mutliple SG"
  # vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "3389", "443", "22"]
    content {
      description = "Allow multiple ports"
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