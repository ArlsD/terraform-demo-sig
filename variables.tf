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
    default     = "demo-sig-key"  
}

variable "s3_bucket_name" {
    description = "Name of the s3 bucket for remote state"
    default     = "tf-demo-sig"
}

variable "name" {
    description = "Name of EC2 instance"
    default     = "prod-instance"
}
