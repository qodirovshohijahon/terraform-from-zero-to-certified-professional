#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
#  Terraform Data Sources
#
# Made by Mustofa Kodirov
#----------------------------------------------------------

provider "aws" {}

data "aws_region" "current_region" {}
data "aws_caller_identity" "current_user" {}
data "aws_availability_zones" "current_az" {}
data "aws_vpcs" "vpcs" {}

data "aws_vpc" "prod" {
  tags = {
    Name = "PROD"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id            = data.aws_vpc.prod.id
  availability_zone = data.aws_availability_zones.current_az.names[0]
  cidr_block        = "10.0.0.0/16"

  tags = {
    Name = "Subnet-1"
    Info = "AZ - ${data.aws_availability_zones.current_az.names[0]} in Region ${data.aws_region.current_region.description}"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id            = data.aws_vpc.prod.id
  availability_zone = data.aws_availability_zones.current_az.names[1]
  cidr_block        = "10.0.0.0/16"

  tags = {
    Name = "Subnet-1"
    Info = "AZ - ${data.aws_availability_zones.current_az.names[1]} in Region ${data.aws_region.current_region.description}"
  }
}


#------------------------Output Section----------------------------#

output "region_name" {
  value = data.aws_region.current_region.name
}
output "region_description" {
  value = data.aws_region.current_region.description
}
output "account_id" {
  value = data.aws_caller_identity.current_user.account_id
}
output "az" {
  value = data.aws_availability_zones.current_az.names
}
output "all_vpcs" {
  value = data.aws_vpcs.vpcs.ids
}