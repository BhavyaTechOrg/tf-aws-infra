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

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Database name"
}
