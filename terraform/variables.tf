variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "ap-south-1" 
}

variable "ami_id" {
  description = "Ubuntu 22.04 LTS AMI ID"
  type        = string
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type"
}

variable "subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}
