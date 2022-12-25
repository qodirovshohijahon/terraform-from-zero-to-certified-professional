#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
#  Execute Commands on Local Terraform Server
#
#  Made by Mustofa Kodir
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform command execution time START: $(date) >> time.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 2 www.google.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    interpreter = ["python", "-c"]
    command     = "print('Hello World from Python!')"
  }
}

resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo Hello I am $NAME in $ENVIRONMENT >> time.txt"
    environment = {
      NAME        = "Ali"
      ENVIRONMENT = "PROD"
    }
  }
}


resource "aws_instance" "myserver" {
  ami           = "ami-026b57f3c383c2eec"
  instance_type = "t3.nano"

  provisioner "local-exec" {
    command = "echo ${aws_instance.myserver.private_ip} >> time.txt"
  }
}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo Terraform FINISH: $(date) >> time.txt"
  }
  depends_on = [
    null_resource.command1,
    null_resource.command2,
    null_resource.command3,
    null_resource.command4,
    aws_instance.myserver
  ]
}