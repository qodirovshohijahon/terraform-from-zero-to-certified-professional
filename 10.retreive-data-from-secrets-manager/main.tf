#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
# Retreive data from SSM Param and Generate
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

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "administrator"
  password             = data.aws_secretsmanager_secret_version.rds_password_version.secret_string
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

# Generating random complex password
resource "random_password" "main" {
    length = 20
    special = true
    override_special = "!#()_"
}

# Store Generetaed Password in SSM Param
resource "aws_secretsmanager_secret" "password" {
    name = "/prod/prod-mysql-rds/password"
    description = "Master DB Password for RDS Database"
    recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "password" {
  secert_id = aws_secretsmanager_secret.password.id
  secret_string = random_password.main.result
}


# Retreive Password SSM
data "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.password.id
  depend_on = [aws_secretsmanager_secret_version.password]
}

#------------------------Output Section----------------------------#
output "rds_endpoint" {
    value = aws_db_instance.rds_instance.address
}
output "rds_rds_port" {
    description = "RDS instance port"
    value = aws_db_instance.rds_instance.port
}
output "rds_username" {
    description = "RDS instance root username"
    value = aws_db_instance.rds_instance.username
    sensitive   = true
}
output "rds_master_db_password" {
    value = data.aws_ssm_parameter.rds_password.value
    sensitive   = true
}