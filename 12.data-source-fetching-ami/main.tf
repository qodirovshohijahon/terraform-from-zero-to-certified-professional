#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
#  Terraform Data Sources fetching AMI
#
#  Made by Mustofa Kodirov
#----------------------------------------------------------

provider "aws" {
  region = "us-east-1"
}

# define latest ubuntu image id
data "aws_ami" "latest_ubuntu20" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220912"]
  }
}
# define latest linux amazon image id
 data "aws_ami" "latest_amazonlinux" {
  owners = ["137112412989"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220912.1-x86_64-gp2"]
  }
}
 # define latest windows19 image id
data "aws_ami" "latest_windows2019" {
  owners = ["801119661308"]
  most_recent = true
  filter {
    name = "name"
    values = ["Windows_Server-2019-English-Full-Base-2022.10.12"]
  }
}

#------------------------Output Section----------------------------#

output "latest_windows2019" {
  value = data.aws_ami.latest_windows2019.id
}
output "latest_amazonlinux" {
  value = data.aws_ami.latest_amazonlinux.id
}
output "latest_ubuntu20" {
  value = data.aws_ami.latest_ubuntu20.id
}