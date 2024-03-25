variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
    description = "Name of the existing EC2 key pair"
    default     = "demo-ec2-key"  
}

variable "s3_bucket_name" {
    description = "Name of the s3 bucket for remote state"
    default     = "tf-demo-sig"
}

variable "name" {
    description = "Name of EC2 instance"
    default     = "prod-instance"
}

variable "vpc" {
  description  = "Name of vpc for EC2 instance"
  default      = "vpc-07a0a05edf290a5f2"
}

variable "security_group_name" {
  description = "Name of secgroup"
  default     = "tf-my-ec2-sec-grp"
}

variable "subnet" {
  description = "Name of subnet"
  default     = "subnet-03368a95527b7c160"
}