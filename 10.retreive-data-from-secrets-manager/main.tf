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
  password             = data.aws_secretsmanager_secret_version.rds_password.secret_string
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

# Generating random complex password
resource "random_password" "main" {
  length           = 20
  special          = true
  override_special = "!#()_"
}

# Store Generetaed Password in SSM Param
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "/prod/rds/password"
  description             = "Master DB Password for RDS Database"
  recovery_window_in_days = 0
}

# Store All Parameters as json in SSM Param
resource "aws_secretsmanager_secret" "rds" {
  name                    = "/prod/rds/all"
  description             = "All Params for RDS Database"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.main.result
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode({
    rds_endpoint           = aws_db_instance.rds_instance.address,
    rds_rds_port           = aws_db_instance.rds_instance.port,
    rds_username           = aws_db_instance.rds_instance.username,
    rds_master_db_password = random_password.main.result
  })
}


# Retreive Password SSM
data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id  = aws_secretsmanager_secret.rds_password.id
  depends_on = [aws_secretsmanager_secret_version.rds_password]
}

# Retrevice All data from SSM
data "aws_secretsmanager_secret_version" "rds" {
  secret_id  = aws_secretsmanager_secret.rds.id
  depends_on = [aws_secretsmanager_secret_version.rds]
}


#------------------------Output Section----------------------------#
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.address
}
output "rds_rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.rds_instance.port
}
output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.rds_instance.username
  sensitive   = true
}
output "rds_master_db_password" {
  value     = aws_secretsmanager_secret.rds_password.id
  sensitive = true
}


output "rds_all" {
  value = jsondecode(
    data.aws_secretsmanager_secret_version.rds.secret_string
  )
  sensitive = true

}