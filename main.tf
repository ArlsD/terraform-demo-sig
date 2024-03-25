terraform {
  backend "s3" {
    bucket                      = "tf-demo-sig"
    key                         = "terraform.tfstate"
    region                      = "ap-south-1"
    encrypt                     = "true"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "prod-instance-sg" {
  name        = var.security_group_name
  vpc_id      = var.vpc

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
}

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name    = "name"
    values  = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "prod-instance" {
  ami             = data.aws_ami.amazon_linux.id
  instance_type   = var.instance_type
  key_name        = var.key_name

  vpc_security_group_ids = [
    aws_security_group.prod-instance-sg.id
  ]
# root_block_device {
#   delete_on_termination = true
#   iops = 150
#   volume_size = 50
#   volume_type = "gp2"
# }
  
  tags = {
    Name = var.name
  }

  depends_on = [ aws_security_group.prod-instance-sg ]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum -y update 
              sudo yum -y install httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              EOF

  lifecycle {
    create_before_destroy = true
  }            
}

output "ec2instance" {
  value = aws_instance.prod-instance.public_ip
}

output "availability_zone" {
  value = aws_instance.prod-instance.availability_zone
}

