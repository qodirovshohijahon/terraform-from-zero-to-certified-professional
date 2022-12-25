#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
#  Execute Commands on Remote Server
#
#  Made by Mustofa Kodir
#----------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "myserver" {
  ami                    = "ami-026b57f3c383c2eec"
  instance_type          = "t3.nano"
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = "demo.pem"
  tags = {
    Name  = "My EC2 with remote-exec"
    Owner = "Mustofa Kodir"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/terraform",
      "cd /home/ec2-user/terraform",
      "touch hello.txt",
      "echo 'Terraform was here...' > terraform.txt"
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip //Same as: aws_instance.myserver.public_ip
      private_key = file("demo.pem")
    }
  }
}


resource "aws_security_group" "web" {
  name   = "My-SecurityGroup"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "SG by Terraform"
    Owner = "Mustofa Kodir"
  }
}