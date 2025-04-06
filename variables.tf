variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile for authentication"
}

variable "environment" {
  type        = string
  description = "Environment tag (e.g., dev, prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnets_cidr" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "name_prefix" {
  type        = string
  description = "A prefix to uniquely identify resources"
}

variable "custom_ami" {
  type        = string
  description = "AMI ID of the custom-built application image"
}

variable "application_port" {
  type        = number
  description = "Port on which the application runs"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 3
}


variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t2.micro"
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2"
  type        = string
}


variable "ssh_allowed_ip" {
  description = "CIDR block allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0" # Override in tfvars for secure environments
}

variable "domain_name" {
  description = "Your root domain name"
  type        = string

}