variable "awsprops" {
    default = {
        region = "ap-south-1"
        vpc = "vpc-07a0a05edf290a5f2"
        ami = "ami-02bb7d8191b50f4bb"
        itype = "t2.micro"
        subnet = "subnet-03368a95527b7c160"
        publicip = "true"
        keyname = "Assignment_Key_b"
        secgroupname = "tf-my-ec2-sec-grp"
  }
}

provider "aws" {
    region = lookup(var.awsprops,"region")
}

resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

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

resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
# root_block_device {
#   delete_on_termination = true
#   iops = 150
#   volume_size = 50
#   volume_type = "gp2"
# }
  tags = {
    Name = "SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  } 

  depends_on = [ aws_security_group.project-iac-sg ]

user_data = <<-EOF
   #!/bin/bash
   echo "Hello from user data script!" > /tmp/user_data_output.txt
   
   # update the system
   sudo yum update -y

   # install docker dependencies
   sudo yum install docker -y
   
   # Start docker service
   sudo service docker start

   # Add the user to docker group 
   sudo usermod-aG docker ec2-user

   # Enable Docker to start on boot 
   sudo chkconfig docker on

   # Install Nginx
   yum install nginx -y 

   # Back up the original Nginx confirguration
   sudo cp /etc/nginx/nginx.conf/etc/nginx/nginx.conf.bak

   # Modify Nginx configuration to proxy requests to the Flask app
   sudo sed -i '/^#/d' /etc/nginx/nginx.conf
   sudo sed -i '/error_page 404/i\
   \
   location/flask {\
      proxy_pass http://localhost:8082/;\
   }\
   \ 
   ' /etc/nginx/nginx.conf
    
    # Start Nginx service 
    sudo systemctl start nginx
    
    # Enable to start on boot
    sudo systemctl enable nginx
    
    # Run the Nginx Docker container
    sudo docker run -d -p 80:80 nginx
  EOF
}

output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}

output "availability_zone"{
  value = aws_instance.project-iac.availability_zone
}
